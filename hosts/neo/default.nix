inputs: with inputs.nixos-hardware.nixosModules; [
    ./configuration.nix
    ./hardware.nix
    dell-xps-15-9560-intel
    common-cpu-intel-kaby-lake
    ({config, ...}: {
        # TODO: Fix commonModules missing
        #specialisation.nvidia = {
        #inheritParentConfig = false;
        #configuration = {
        #    imports = [
        #    ./hosts/neo
        #    inputs.nixos-hardware.nixosModules.dell-xps-15-9560-nvidia
        #    common-cpu-intel-kaby-lake
        #    ] ++ commonModules "x86_64-linux";

        #    modules.desktop.environment = lib.mkForce "i3";
        #    hardware.nvidia = {
        #    prime = {
        #        offload.enable = false;
        #        sync.enable = true;
        #    };
        #    modesetting.enable = true;
        #    };
        #};
        #};
    })
]