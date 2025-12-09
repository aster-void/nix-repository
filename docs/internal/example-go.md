# Go Packaging Example

## Basic Structure

```nix
# packages/my-go-app/package.nix
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "my-go-app";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "my-go-app";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  vendorHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  # Optional: specify which subpackages to build
  subPackages = ["cmd/my-go-app"];

  # Optional: strip debug info for smaller binary
  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Short description of the application";
    homepage = "https://github.com/owner/my-go-app";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "my-go-app";
  };
}
```

## Key Attributes

| Attribute     | Description                                                                                                  |
| ------------- | ------------------------------------------------------------------------------------------------------------ |
| `vendorHash`  | Hash of vendored dependencies. Use `lib.fakeHash` initially, then replace with actual hash from build error. |
| `subPackages` | List of Go packages to build (relative to `src`). Useful for monorepos.                                      |
| `ldflags`     | Linker flags. `-s -w` strips debug info.                                                                     |
| `doCheck`     | Set to `false` if tests require network access.                                                              |

## Getting Hashes

1. Set `hash` and `vendorHash` to placeholder:

   ```nix
   hash = lib.fakeHash;
   vendorHash = lib.fakeHash;
   ```

2. Run `nix build .#my-go-app` and copy the correct hashes from error messages.

## Real Example

See [packages/gwq/package.nix](../packages/gwq/package.nix) or [packages/mcptools/package.nix](../packages/mcptools/package.nix).
