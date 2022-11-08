with (import (fetchTarball https://github.com/nixos/nixpkgs/archive/592dc9ed7f049c565e9d7c04a4907e57ae17e2d9.tar.gz) {});

let
  gems = bundlerEnv {

    ruby = ruby_3_1;
    name = "development";
    gemdir = ./.;
    lockfile = pkgs.runCommand "platformless-gemfile" {} ''
      sed '/^PLATFORMS/,/^$/d' ${./Gemfile.lock} > $out
      echo -e "PLATFORMS\n  ruby" >> $out
    '';
  };
in mkShell {
  buildInputs = [
    gems
    gems.wrappedRuby
    postgresql_13
    redis
    overmind
    git
    bundix
    vim
  ];

  # Put the PostgreSQL in a gitignored subdirectory.
  shellHook = ''
    export PGDATA="$PWD/pg_data"
    export DATABASE_URL=postgresql://localhost:5450
    export PORT=5170
  '';
}
