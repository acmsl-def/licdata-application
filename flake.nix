# flake.nix
#
# This file packages acmsl/licdata-application as a Nix flake.
#
# Copyright (C) 2024-today acm-sl's Licdata Application
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description = "Nix flake for acmsl/licdata-application";
  inputs = rec {
    acmsl-licdata-domain = {
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      url = "github:acmsl-def/licdata-domain/0.0.20";
      inputs.acmsl-licdata-events.follows =
        "acmsl-licdata-events";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
    };
    acmsl-licdata-events = {
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      url = "github:acmsl-def/licdata-events/0.0.21";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
    };
    acmsl-licdata-infrastructure = {
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      url = "github:acmsl-def/licdata-infrastructure/0.0.24";
      inputs.acmsl-licdata-domain.follows =
        "acmsl-licdata-domain";
      inputs.acmsl-licdata-events.follows =
        "acmsl-licdata-events";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
    };
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixpkgs.url = "github:NixOS/nixpkgs/24.05";
    pythoneda-shared-pythonlang-banner = {
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      url = "github:pythoneda-shared-pythonlang-def/banner/0.0.74";
    };
    pythoneda-shared-pythonlang-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      url = "github:pythoneda-shared-pythonlang-def/domain/0.0.110";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        org = "acmsl";
        repo = "licdata-application";
        version = "0.0.3";
        sha256 = "0j61cjvlzysljfr4704l5f23229fwli3ggnpnrxrmq9782vjs966";
        pname = "${org}-${repo}";
        pythonpackage = "org.acmsl.licdata.application";
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        pkgs = import nixpkgs { inherit system; };
        description = "Licdata Application";
        entrypoint = "licdata_app";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        archRole = "B";
        space = "D";
        layer = "A";
        nixpkgsVersion = builtins.readFile "${nixpkgs}/.version";
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixpkgs-${nixpkgsVersion}";
        shared = import "${pythoneda-shared-pythonlang-banner}/nix/shared.nix";
        acmsl-licdata-application-for = { acmsl-licdata-events, acmsl-licdata-domain, acmsl-licdata-infrastructure, python
          , pythoneda-shared-pythonlang-banner
          , pythoneda-shared-pythonlang-domain}:
          let
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
            banner_file = "${package}/licdata_app_banner.py";
            banner_class = "LicdataAppBanner";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTomlTemplate = ./templates/pyproject.toml.template;
            pyprojectToml = pkgs.substituteAll {
              acmslLicdataDomain = acmsl-licdata-domain.version;
              acmslLicdataEvents = acmsl-licdata-events.version;
              acmslLicdataInfrastructure = acmsl-licdata-infrastructure.version;
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage pname pythonMajorMinorVersion package
                version;
              pythonedaSharedPythonlangBanner =
                pythoneda-shared-pythonlang-banner.version;
              pythonedaSharedPythonlangDomain =
                pythoneda-shared-pythonlang-domain.version;
              src = pyprojectTomlTemplate;
            };

            bannerTemplateFile = ./templates/banner.py.template;
            bannerTemplate = pkgs.substituteAll {
              project_name = pname;
              file_path = banner_file;
              inherit banner_class org repo;
              tag = version;
              pescio_space = space;
              arch_role = archRole;
              hexagonal_layer = layer;
              python_version = pythonMajorMinorVersion;
              nixpkgs_release = nixpkgsRelease;
              src = bannerTemplateFile;
            };

            entrypointTemplateFile =
              "${pythoneda-shared-pythonlang-banner}/templates/entrypoint.sh.template";
            entrypointTemplate = pkgs.substituteAll {
              arch_role = archRole;
              hexagonal_layer = layer;
              nixpkgs_release = nixpkgsRelease;
              inherit homepage maintainers org python repo version;
              pescio_space = space;
              python_version = pythonMajorMinorVersion;
              pythoneda_shared_pythoneda_banner =
                pythoneda-shared-pythonlang-banner;
              pythoneda_shared_pythoneda_domain =
                pythoneda-shared-pythonlang-domain;
              src = entrypointTemplateFile;
            };

            src = pkgs.fetchFromGitHub {
              owner = org;
              rev = version;
              inherit repo sha256;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip poetry-core ] ++ [ pkgs.zip ];
            propagatedBuildInputs = with python.pkgs; [
              acmsl-licdata-domain
              acmsl-licdata-events
              acmsl-licdata-infrastructure
              pythoneda-shared-pythonlang-banner
              pythoneda-shared-pythonlang-domain
            ];

            # pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              command cp -r ${src} .
              sourceRoot=$(command ls | command grep -v env-vars)
              command chmod -R +w $sourceRoot
              command cp ${pyprojectToml} $sourceRoot/pyproject.toml
              command cp ${bannerTemplate} $sourceRoot/${banner_file}
              command cp ${entrypointTemplate} $sourceRoot/entrypoint.sh
            '';

            postPatch = ''
              substituteInPlace /build/$sourceRoot/entrypoint.sh \
                --replace "@SOURCE@" "$out/bin/${entrypoint}.sh" \
                --replace "@PYTHONEDA_EXTRA_NAMESPACES@" "org" \
                --replace "@PYTHONPATH@" "$PYTHONPATH" \
                --replace "@CUSTOM_CONTENT@" "" \
                --replace "@PYTHONEDA_SHARED_PYTHONLANG_DOMAIN@" "${pythoneda-shared-pythonlang-domain}" \
                --replace "@PACKAGE@" "$out/lib/python${pythonMajorMinorVersion}/site-packages" \
                --replace "@ENTRYPOINT@" "$out/lib/python${pythonMajorMinorVersion}/site-packages/${package}/application/${entrypoint}.py" \
                --replace "@BANNER@" "$out/bin/banner.sh"
            '';

            postInstall = with python.pkgs; ''
              command pushd /build/$sourceRoot
              for f in $(command find . -name '__init__.py' | grep -v '.deps' | sed 's ^\./  g'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  command mkdir -p $out/lib/python${pythonMajorMinorVersion}/site-packages/"$(command dirname $f)";
                  command cp -r "$(command dirname $f)"/* $out/lib/python${pythonMajorMinorVersion}/site-packages/"$(command dirname $f)";
                fi
              done
              command popd
              command mkdir -p $out/dist $out/deps/flakes
              command pip freeze | grep -v 'acmsl' | grep -v 'pythoneda' | grep -v 'rydnr' | grep -v 'stringtemplate3' | grep -v 'smmap' > /build/$sourceRoot/requirements.txt
              command cp dist/${wheelName} $out/dist
              command cp /build/$sourceRoot/entrypoint.sh $out/bin/${entrypoint}.sh
              command chmod +x $out/bin/${entrypoint}.sh
              command echo '#!/usr/bin/env sh' > $out/bin/banner.sh
              command echo "export PYTHONPATH=$PYTHONPATH" >> $out/bin/banner.sh
              command echo "command echo 'Running $out/bin/banner'" >> $out/bin/banner.sh
              command echo "${python}/bin/python $out/lib/python${pythonMajorMinorVersion}/site-packages/${banner_file} \$@" >> $out/bin/banner.sh
              command chmod +x $out/bin/banner.sh
              for dep in ${acmsl-licdata-domain} ${acmsl-licdata-events} ${acmsl-licdata-infrastructure} ${pythoneda-shared-pythonlang-banner} ${pythoneda-shared-pythonlang-domain}; do
                command cp -r $dep/dist/* $out/deps || true
                if [ -e $dep/deps ]; then
                  command cp -r $dep/deps/* $out/deps || true
                fi
                METADATA=$dep/lib/python${pythonMajorMinorVersion}/site-packages/*.dist-info/METADATA
                NAME="$(command grep -m 1 '^Name: ' $METADATA | command cut -d ' ' -f 2)"
                VERSION="$(command grep -m 1 '^Version: ' $METADATA | command cut -d ' ' -f 2)"
                command ln -s $dep $out/deps/flakes/$NAME-$VERSION || true
              done
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        apps = rec {
          default = acmsl-licdata-application-python312;
          acmsl-licdata-application-python39 = shared.app-for {
            package =
              self.packages.${system}.licdata-python39;
            inherit entrypoint;
          };
          acmsl-licdata-application-python310 = shared.app-for {
            package =
              self.packages.${system}.licdata-python310;
            inherit entrypoint;
          };
          acmsl-licdata-application-python311 = shared.app-for {
            package =
              self.packages.${system}.licdata-python311;
            inherit entrypoint;
          };
          acmsl-licdata-application-python312 = shared.app-for {
            package =
              self.packages.${system}.licdata-python312;
            inherit entrypoint;
          };
          acmsl-licdata-application-python313 = shared.app-for {
            package =
              self.packages.${system}.licdata-python313;
            inherit entrypoint;
          };
        };
        defaultApp = apps.default;
        defaultPackage = packages.default;
        devShells = rec {
          default = acmsl-licdata-application-python312;
          acmsl-licdata-application-python39 =
            shared.devShell-for {
              banner = "${packages.acmsl-licdata-application-python39}/bin/banner.sh";
              extra-namespaces = "org";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.acmsl-licdata-application-python39;
              python = pkgs.python39;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python39;
              inherit archRole layer org pkgs repo space;
            };
          acmsl-licdata-application-python310 =
            shared.devShell-for {
              banner = "${packages.acmsl-licdata-application-python310}/bin/banner.sh";
              extra-namespaces = "org";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.acmsl-licdata-application-python310;
              python = pkgs.python310;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python310;
              inherit archRole layer org pkgs repo space;
            };
          acmsl-licdata-application-python311 =
            shared.devShell-for {
              banner = "${packages.acmsl-licdata-application-python311}/bin/banner.sh";
              extra-namespaces = "org";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.acmsl-licdata-application-python311;
              python = pkgs.python311;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python311;
              inherit archRole layer org pkgs repo space;
            };
          acmsl-licdata-application-python312 =
            shared.devShell-for {
              banner = "${packages.acmsl-licdata-application-python312}/bin/banner.sh";
              extra-namespaces = "org";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.acmsl-licdata-application-python312;
              python = pkgs.python312;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python312;
              inherit archRole layer org pkgs repo space;
            };
          acmsl-licdata-application-python313 =
            shared.devShell-for {
              banner = "${packages.acmsl-licdata-application-python313}/bin/banner.sh";
              extra-namespaces = "org";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.acmsl-licdata-application-python313;
              python = pkgs.python313;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python313;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python313;
              inherit archRole layer org pkgs repo space;
            };
        };
        packages = rec {
          default = acmsl-licdata-application-python312;
          acmsl-licdata-application-python39 =
            acmsl-licdata-application-for {
              acmsl-licdata-domain = acmsl-licdata-domain.packages.${system}.acmsl-licdata-domain-python39;
              acmsl-licdata-events = acmsl-licdata-events.packages.${system}.acmsl-licdata-events-python39;
              acmsl-licdata-infrastructure = acmsl-licdata-infrastructure.packages.${system}.acmsl-licdata-infrastructure-python39;
              python = pkgs.python39;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python39;
            };
          acmsl-licdata-application-python310 =
            acmsl-licdata-application-for {
              acmsl-licdata-domain = acmsl-licdata-domain.packages.${system}.acmsl-licdata-domain-python310;
              acmsl-licdata-events = acmsl-licdata-events.packages.${system}.acmsl-licdata-events-python310;
              acmsl-licdata-infrastructure = acmsl-licdata-infrastructure.packages.${system}.acmsl-licdata-infrastructure-python310;
              python = pkgs.python310;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python310;
            };
          acmsl-licdata-application-python311 =
            acmsl-licdata-application-for {
              acmsl-licdata-domain = acmsl-licdata-domain.packages.${system}.acmsl-licdata-domain-python311;
              acmsl-licdata-events = acmsl-licdata-events.packages.${system}.acmsl-licdata-events-python311;
              acmsl-licdata-infrastructure = acmsl-licdata-infrastructure.packages.${system}.acmsl-licdata-infrastructure-python311;
              python = pkgs.python311;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python311;
            };
          acmsl-licdata-application-python312 =
            acmsl-licdata-application-for {
              acmsl-licdata-domain = acmsl-licdata-domain.packages.${system}.acmsl-licdata-domain-python312;
              acmsl-licdata-events = acmsl-licdata-events.packages.${system}.acmsl-licdata-events-python312;
              acmsl-licdata-infrastructure = acmsl-licdata-infrastructure.packages.${system}.acmsl-licdata-infrastructure-python312;
              python = pkgs.python312;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python312;
            };
          acmsl-licdata-application-python313 =
            acmsl-licdata-application-for {
              acmsl-licdata-domain = acmsl-licdata-domain.packages.${system}.acmsl-licdata-domain-python313;
              acmsl-licdata-events = acmsl-licdata-events.packages.${system}.acmsl-licdata-events-python313;
              acmsl-licdata-infrastructure = acmsl-licdata-infrastructure.packages.${system}.acmsl-licdata-infrastructure-python313;
              python = pkgs.python313;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python313;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python313;
            };
        };
      });
}
