mod archive;
mod generator;
mod model;

pub use generator::{
    GenerateError, GeneratedFile, GeneratedProject, ValidationIssue, ValidationReport,
    generate_project, parse_spec, validate_spec,
};
pub use model::{
    Alignment, Element, Font, FontFamily, FontHeights, LetterSpacing, ProjectSpec, TimeFormat,
};

pub fn validate_project_json(json: &str) -> String {
    let report = match parse_spec(json) {
        Ok(spec) => validate_spec(&spec),
        Err(error) => ValidationReport {
            valid: false,
            issues: vec![ValidationIssue {
                field: "$".to_owned(),
                message: error.to_string(),
            }],
        },
    };

    serde_json::to_string(&report).expect("validation report is serializable")
}

pub fn export_project_zip(json: &str) -> Result<Vec<u8>, String> {
    let spec = parse_spec(json).map_err(|error| error.to_string())?;
    let project = generate_project(&spec).map_err(|error| error.to_string())?;
    archive::create_zip(&project.folder_name, &project.files).map_err(|error| error.to_string())
}

#[cfg(target_arch = "wasm32")]
mod wasm {
    use std::ptr;
    use std::slice;

    #[unsafe(no_mangle)]
    pub extern "C" fn garatch_alloc(length: usize) -> *mut u8 {
        let buffer = vec![0_u8; length].into_boxed_slice();
        Box::into_raw(buffer) as *mut u8
    }

    #[unsafe(no_mangle)]
    pub unsafe extern "C" fn garatch_free(pointer: *mut u8, length: usize) {
        if pointer.is_null() || length == 0 {
            return;
        }
        let slice_pointer = ptr::slice_from_raw_parts_mut(pointer, length);
        // SAFETY: `pointer` and `length` originate from `garatch_alloc` or
        // `pack_result`, both of which allocate an exact-length boxed slice.
        unsafe { drop(Box::from_raw(slice_pointer)) };
    }

    #[unsafe(no_mangle)]
    pub unsafe extern "C" fn garatch_validate(pointer: *const u8, length: usize) -> *mut u8 {
        // SAFETY: this function has the same pointer and lifetime contract as
        // `with_json`; the browser wrapper owns the allocation for this call.
        unsafe {
            with_json(pointer, length, |json| {
                Ok(super::validate_project_json(json).into_bytes())
            })
        }
    }

    #[unsafe(no_mangle)]
    pub unsafe extern "C" fn garatch_export_project_zip(
        pointer: *const u8,
        length: usize,
    ) -> *mut u8 {
        // SAFETY: this function has the same pointer and lifetime contract as
        // `with_json`; the browser wrapper owns the allocation for this call.
        unsafe { with_json(pointer, length, super::export_project_zip) }
    }

    unsafe fn with_json(
        pointer: *const u8,
        length: usize,
        operation: impl FnOnce(&str) -> Result<Vec<u8>, String>,
    ) -> *mut u8 {
        if pointer.is_null() {
            return pack_result(Err("input pointer is null".to_owned()));
        }
        // SAFETY: the browser wrapper allocates this region with
        // `garatch_alloc`, writes exactly `length` bytes, and keeps it alive for
        // the duration of this call.
        let input = unsafe { slice::from_raw_parts(pointer, length) };
        let json = match std::str::from_utf8(input) {
            Ok(json) => json,
            Err(error) => return pack_result(Err(format!("input is not UTF-8: {error}"))),
        };
        pack_result(operation(json))
    }

    fn pack_result(result: Result<Vec<u8>, String>) -> *mut u8 {
        let (status, payload) = match result {
            Ok(payload) => (0_u32, payload),
            Err(error) => (1_u32, error.into_bytes()),
        };
        let payload_length = match u32::try_from(payload.len()) {
            Ok(length) => length,
            Err(_) => return pack_result(Err("result exceeds 4 GiB".to_owned())),
        };
        let mut output = Vec::with_capacity(8 + payload.len());
        output.extend_from_slice(&status.to_le_bytes());
        output.extend_from_slice(&payload_length.to_le_bytes());
        output.extend_from_slice(&payload);
        Box::into_raw(output.into_boxed_slice()) as *mut u8
    }
}
