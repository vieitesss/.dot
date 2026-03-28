{ config, flakeDirectory, ... }:

{
  home.file.".config/rio".source = config.lib.file.mkOutOfStoreSymlink "${flakeDirectory}/config/rio";
}
