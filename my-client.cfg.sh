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

set -x
CFG="${CFGDIR}/Engine.ini"
SEC="/Script/Engine.RendererSettings"
crudini --set "$CFG" "$SEC" r.DefaultFeature.Bloom False
crudini --set "$CFG" "$SEC" r.DefaultFeature.AmbientOcclusion False
crudini --set "$CFG" "$SEC" r.DefaultFeature.AutoExposure False
crudini --set "$CFG" "$SEC" r.DefaultFeature.MotionBlur False
crudini --set "$CFG" "$SEC" r.DefaultFeature.LensFlare False
crudini --set "$CFG" "$SEC" r.DefaultFeature.AntiAliasing 0

CFG="${CFGDIR}/Scalability.ini"
SEC="PostProcessQuality@0"
crudini --set "$CFG" "$SEC" r.BloomQuality 0
crudini --set "$CFG" "$SEC" r.LightShafts 0
SEC="PostProcessQuality@1"
crudini --set "$CFG" "$SEC" r.BloomQuality 0
crudini --set "$CFG" "$SEC" r.LightShafts 0
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
