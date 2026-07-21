const encoder = new TextEncoder();
const decoder = new TextDecoder();

async function instantiateWasm(url) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`The exporter is not ready (${response.status}). Rebuild the app and reload this page.`);
  }
  try {
    return await WebAssembly.instantiateStreaming(response.clone(), {});
  } catch {
    return WebAssembly.instantiate(await response.arrayBuffer(), {});
  }
}

class GaratchCore {
  constructor(instance) {
    this.exports = instance.exports;
    const required = ["memory", "garatch_alloc", "garatch_free", "garatch_validate", "garatch_export_project_zip"];
    const missing = required.filter((name) => !(name in this.exports));
    if (missing.length) throw new Error("The exporter did not load correctly. Rebuild the app and try again.");
  }

  call(exportName, project) {
    const input = encoder.encode(JSON.stringify(project));
    const inputPointer = this.exports.garatch_alloc(input.byteLength);
    if (!inputPointer && input.byteLength > 0) throw new Error("The exporter could not prepare this project.");
    try {
      new Uint8Array(this.exports.memory.buffer, inputPointer, input.byteLength).set(input);
      const resultPointer = this.exports[exportName](inputPointer, input.byteLength);
      if (!resultPointer) throw new Error("The exporter returned an empty project.");
      const header = new DataView(this.exports.memory.buffer, resultPointer, 8);
      const status = header.getUint32(0, true);
      const payloadLength = header.getUint32(4, true);
      const payload = new Uint8Array(this.exports.memory.buffer, resultPointer + 8, payloadLength).slice();
      this.exports.garatch_free(resultPointer, 8 + payloadLength);
      if (status !== 0) throw new Error(decoder.decode(payload));
      return payload;
    } finally {
      this.exports.garatch_free(inputPointer, input.byteLength);
    }
  }

  validate(project) {
    return JSON.parse(decoder.decode(this.call("garatch_validate", project)));
  }

  exportProject(project) {
    return this.call("garatch_export_project_zip", project);
  }
}

export async function loadGaratchCore() {
  const wasmUrl = new URL("../../target/wasm32-unknown-unknown/release/garatch_designer_core.wasm", import.meta.url);
  const { instance } = await instantiateWasm(wasmUrl);
  return new GaratchCore(instance);
}
