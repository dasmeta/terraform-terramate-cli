# Tasks

- [x] Review `v1.0.4..v1.2.2` upstream to size the renderer root-module bump.
- [x] Baseline the examples against the old pins before changing anything.
- [x] Bump the `infra-yaml-loader` pin to 1.2.2.
- [x] Bump the renderer root pin in `modules/stack` from 1.0.4 to 1.2.2.
- [x] Raise `required_version` to `~> 1.8` for the root module and `modules/stack`.
- [x] Update README requirement and module tables.
- [x] Plan every example and confirm no new failing checks.
- [x] Confirm renderer-generated files are unchanged by the bump.
- [x] Add `AGENTS.md` diagnostic guide.
- [ ] Publish a new driver version after merge to `main`.
- [ ] Regenerate drifted example output (`stack.tm.hcl` ids) as separate cleanup.
