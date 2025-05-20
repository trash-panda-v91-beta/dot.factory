_: {
  config = {
    programs.yazi = {
      enable = true;
    };
    programs.fish = {
      shellAbbrs = {
        yy = "yazi";
      };
    };
  };
}
