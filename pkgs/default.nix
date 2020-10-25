# Written like (import ./<category name 1> prev) // (import ./<category name 2> prev)
# There should be no collisions to worry about
{ prev, kernelVer }:
(import ./tools prev) // (import ./drivers { inherit prev kernelVer; })
// (import ./data prev)
