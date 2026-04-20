{
  flake.modules.homeManager.media = { pkgs, ... }: {
    home.packages = with pkgs; [
      imagemagick
      chafa
      ffmpeg
      yt-dlp
    ];
  };
}
