.PHONY: build check dev serve

build:
	cargo build --release --target wasm32-unknown-unknown
	npm ci
	npm run build

check:
	cargo fmt -- --check
	cargo clippy --all-targets -- -D warnings
	cargo test
	cargo build --release --target wasm32-unknown-unknown
	npm ci
	npm run check
	npm run build

dev:
	cargo build --release --target wasm32-unknown-unknown
	npm ci
	npm run dev

serve: build
	python3 -m http.server 4173 --bind 127.0.0.1 --directory ..
