#!/bin/bash
set -e

if ! command -v crudini > /dev/null; then
    echo "Crudini CLI tool:   [MISSING]"
    echo ""
    echo "Get it like:"
    echo "  yum install crudini"
    echo "or"
    echo "  pip install crudini"
    echo "or whatever works for your distro ..."
    exit 1
fi
echo "Crudini CLI tool: OK"

ARKDIR="${ARKDIR:-$HOME/.local/share/Steam/steamapps/common/ARK}"

if [[ ! -d "$ARKDIR" ]]; then
    echo "Seems ARK directory  does not exists."
    echo "\$ARKDIR: ${ARKDIR}   [MISSING]"
    exit 1
fi
echo "\$ARKDIR: ${ARKDIR}"

CFGDIR="${CFGDIR:-${ARKDIR}/ShooterGame/Saved/Config/LinuxNoEditor}"
if [[ ! -d "$CFGDIR" ]]; then
    echo "Seems that directory with saved configs does not exists."
    echo "\$CFGDIR: ${CFGDIR}   [MISSING]"
    exit 1
fi
echo "\$CFGDIR: ${CFGDIR}"

cfg() { crudini --set "$CONFIG_FILE" "$SECTION" "$1" $2; }

set -x

CONFIG_FILE="${CFGDIR}/Engine.ini"
SECTION="/Script/Engine.RendererSettings"
cfg r.DefaultFeature.Bloom False
cfg r.DefaultFeature.AmbientOcclusion False
cfg r.DefaultFeature.AutoExposure False
cfg r.DefaultFeature.MotionBlur False
cfg r.DefaultFeature.LensFlare False
cfg r.DefaultFeature.AntiAliasing 0
cfg r.BloomQuality 0
cfg r.Shadow.MaxResolution 0
cfg r.SSAOSmartBlur 0
cfg r.HZBOcclusion 0
cfg r.DistanceFieldShadowing 0

CFG="${CFGDIR}/Scalability.ini"
SEC="PostProcessQuality@0"
crudini --set "$CFG" "$SEC" r.BloomQuality 0
crudini --set "$CFG" "$SEC" r.LightShafts 0
crudini --set "$CFG" "$SEC" r.LightShaftQuality 0
crudini --set "$CFG" "$SEC" r.LensFlareQuality 0
SEC="PostProcessQuality@1"
crudini --set "$CFG" "$SEC" r.BloomQuality 0
crudini --set "$CFG" "$SEC" r.LightShafts 0
crudini --set "$CFG" "$SEC" r.LightShaftQuality 0
crudini --set "$CFG" "$SEC" r.LensFlareQuality 0
SEC="PostProcessQuality@2"
crudini --set "$CFG" "$SEC" r.BloomQuality 0
crudini --set "$CFG" "$SEC" r.LightShafts 0
crudini --set "$CFG" "$SEC" r.LightShaftQuality 0
crudini --set "$CFG" "$SEC" r.LensFlareQuality 0
SEC="PostProcessQuality@3"
crudini --set "$CFG" "$SEC" r.BloomQuality 0
crudini --set "$CFG" "$SEC" r.LightShafts 0
crudini --set "$CFG" "$SEC" r.LightShaftQuality 0
crudini --set "$CFG" "$SEC" r.LensFlareQuality 0
