use std::fmt;

use crate::generator::GeneratedFile;

const LOCAL_FILE_HEADER: u32 = 0x0403_4b50;
const CENTRAL_DIRECTORY_HEADER: u32 = 0x0201_4b50;
const END_OF_CENTRAL_DIRECTORY: u32 = 0x0605_4b50;
const ZIP_VERSION_20: u16 = 20;
const STORED: u16 = 0;
const DOS_TIME_MIDNIGHT: u16 = 0;
const DOS_DATE_1980_01_01: u16 = (1 << 5) | 1;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ArchiveError {
    TooManyFiles,
    FileNameTooLong(String),
    FileTooLarge(String),
    ArchiveTooLarge,
}

impl fmt::Display for ArchiveError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::TooManyFiles => write!(formatter, "ZIP contains more than 65,535 files"),
            Self::FileNameTooLong(path) => {
                write!(formatter, "ZIP path exceeds 65,535 bytes: {path}")
            }
            Self::FileTooLarge(path) => write!(formatter, "ZIP entry exceeds 4 GiB: {path}"),
            Self::ArchiveTooLarge => {
                write!(formatter, "ZIP archive exceeds the classic 4 GiB limit")
            }
        }
    }
}

impl std::error::Error for ArchiveError {}

struct CentralEntry {
    name: Vec<u8>,
    crc32: u32,
    size: u32,
    local_offset: u32,
}

pub fn create_zip(root: &str, files: &[GeneratedFile]) -> Result<Vec<u8>, ArchiveError> {
    let file_count = u16::try_from(files.len()).map_err(|_| ArchiveError::TooManyFiles)?;
    let mut output = Vec::new();
    let mut central_entries = Vec::with_capacity(files.len());

    for file in files {
        let name = format!("{root}/{}", file.path).into_bytes();
        let name_length = u16::try_from(name.len())
            .map_err(|_| ArchiveError::FileNameTooLong(file.path.clone()))?;
        let size = u32::try_from(file.bytes.len())
            .map_err(|_| ArchiveError::FileTooLarge(file.path.clone()))?;
        let local_offset =
            u32::try_from(output.len()).map_err(|_| ArchiveError::ArchiveTooLarge)?;
        let checksum = crc32(&file.bytes);

        push_u32(&mut output, LOCAL_FILE_HEADER);
        push_u16(&mut output, ZIP_VERSION_20);
        push_u16(&mut output, 0);
        push_u16(&mut output, STORED);
        push_u16(&mut output, DOS_TIME_MIDNIGHT);
        push_u16(&mut output, DOS_DATE_1980_01_01);
        push_u32(&mut output, checksum);
        push_u32(&mut output, size);
        push_u32(&mut output, size);
        push_u16(&mut output, name_length);
        push_u16(&mut output, 0);
        output.extend_from_slice(&name);
        output.extend_from_slice(&file.bytes);

        central_entries.push(CentralEntry {
            name,
            crc32: checksum,
            size,
            local_offset,
        });
    }

    let central_offset = u32::try_from(output.len()).map_err(|_| ArchiveError::ArchiveTooLarge)?;
    for entry in central_entries {
        let name_length = u16::try_from(entry.name.len()).expect("validated path length");
        push_u32(&mut output, CENTRAL_DIRECTORY_HEADER);
        push_u16(&mut output, ZIP_VERSION_20);
        push_u16(&mut output, ZIP_VERSION_20);
        push_u16(&mut output, 0);
        push_u16(&mut output, STORED);
        push_u16(&mut output, DOS_TIME_MIDNIGHT);
        push_u16(&mut output, DOS_DATE_1980_01_01);
        push_u32(&mut output, entry.crc32);
        push_u32(&mut output, entry.size);
        push_u32(&mut output, entry.size);
        push_u16(&mut output, name_length);
        push_u16(&mut output, 0);
        push_u16(&mut output, 0);
        push_u16(&mut output, 0);
        push_u16(&mut output, 0);
        push_u32(&mut output, 0);
        push_u32(&mut output, entry.local_offset);
        output.extend_from_slice(&entry.name);
    }

    let central_end = u32::try_from(output.len()).map_err(|_| ArchiveError::ArchiveTooLarge)?;
    let central_size = central_end
        .checked_sub(central_offset)
        .ok_or(ArchiveError::ArchiveTooLarge)?;

    push_u32(&mut output, END_OF_CENTRAL_DIRECTORY);
    push_u16(&mut output, 0);
    push_u16(&mut output, 0);
    push_u16(&mut output, file_count);
    push_u16(&mut output, file_count);
    push_u32(&mut output, central_size);
    push_u32(&mut output, central_offset);
    push_u16(&mut output, 0);

    Ok(output)
}

fn push_u16(output: &mut Vec<u8>, value: u16) {
    output.extend_from_slice(&value.to_le_bytes());
}

fn push_u32(output: &mut Vec<u8>, value: u32) {
    output.extend_from_slice(&value.to_le_bytes());
}

fn crc32(bytes: &[u8]) -> u32 {
    let mut checksum = 0xffff_ffffu32;
    for byte in bytes {
        checksum ^= u32::from(*byte);
        for _ in 0..8 {
            let mask = 0u32.wrapping_sub(checksum & 1);
            checksum = (checksum >> 1) ^ (0xedb8_8320 & mask);
        }
    }
    !checksum
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn crc32_matches_the_standard_test_vector() {
        assert_eq!(crc32(b"123456789"), 0xcbf4_3926);
    }

    #[test]
    fn writes_local_and_central_directory_headers() {
        let archive = create_zip(
            "sample",
            &[GeneratedFile {
                path: "hello.txt".to_owned(),
                bytes: b"hello".to_vec(),
            }],
        )
        .unwrap();

        assert_eq!(&archive[0..4], &LOCAL_FILE_HEADER.to_le_bytes());
        assert!(
            archive
                .windows(4)
                .any(|window| window == CENTRAL_DIRECTORY_HEADER.to_le_bytes())
        );
        assert!(archive.ends_with(&[0, 0]));
    }
}
