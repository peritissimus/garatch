export function smoothHistorySamples(samples = []) {
  if (samples.length < 3) return [...samples];
  return samples.map((sample, index) => {
    const start = Math.max(0, index - 2);
    const end = Math.min(samples.length - 1, index + 2);
    let total = 0;
    for (let sampleIndex = start; sampleIndex <= end; sampleIndex += 1) total += samples[sampleIndex];
    return total / (end - start + 1);
  });
}
