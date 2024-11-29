#!/usr/bin/env bash

set -eu

# Check for missing prerequisites, and bail early if anything is amiss
if ! which adb &>/dev/null; then
    echo 'ADB not installed. Pleases install and pair with your device' 1>&2
    exit 1
fi

if ! which jq &>/dev/null; then
    echo 'JQ is required for installation of latest packages from F-Droid' 1>&2
    exit 2
fi

# If not connected via adb to a device, exit early
if ! adb devices | grep -q 'device$'; then
    echo 'No Android device connected via adb. Aborting'
    exit 2
fi

# Disable unnecessary packages
source bad_pkgs.sh
for pkg in ${pkgs_to_disable[@]}; do
    # TODO: If package can not be disabled, uninstall it.
    # TODO: Very likely that I want to discern between packages
    # TODO: that should be disabled, and packages that can be uninstalled...
    #echo "Attempting to disable '${pkg}' ..." 1>&2
    set -x
    if ! adb shell pm disable "${pkg}"; then
        #echo "ERROR: Package '${pkg}' could not be disabled" 1>&2
        if ! adb shell pm -k --user 2000 disable "${pkg}"; then
            # Alternative; for Android Lollipop and above
            if ! adb shell pm hide "${pkg}"; then
                #echo "ERROR: Package '${pkg}' could not be hidden as user 0" 1>&2
                if ! adb shell pm hide -k --user 2000 "${pkg}"; then
                    #echo "ERROR: Package '${pkg}' could not be hidden as user 2000" 1>&2
                    # alternative; package remains visible in Launcher and Settings app but cannot be used; a feature of Device Administratin
                    if ! adb shell pm disable "${pkg}"; then
                        true
                        #if ! adb shell pm disable -k --user 2000 "${pkg}"; then
                            true
                            if ! adb shell cmd package suspend "${pkg}"; then
                                #echo "ERROR: Package '${pkg}' could not be suspended" 1>&2
                                if ! adb shell pm uninstall -k --user 0 "${pkg}"; then
                                    #echo "Package '${pkg}' could not be uninstalled as user 0" 1>&2
                                    if ! adb shell pm uninstall -k --user 2000 "${pkg}"; then
                                        #echo "Package '${pkg}' could not be uninstalled as user 2000" 1>&2
                                        true
                                    fi
                                    true
                                fi
                            fi
                        #fi
                    fi
                fi
            fi
        fi
    fi
    set +x
done

# Install extra packages

pushd /tmp &>/dev/null
# F-Droid Basic (FLOSS package manager with reproducible builds
if ! adb shell pm list packages | grep -q '^package:org.fdroid.basic'; then
    curl -o fdroid_basic.apk 'https://f-droid.org/repo/org.fdroid.basic_1021051.apk$' && adb install ./fdroid_basic.apk && rm -f ./fdroid_basic.apk
fi

# Aurora Store (Google Play Store replacement)
if ! adb shell pm list packages | grep -q '^package:com.aurora.store$'; then
    curl -o aurora_store.apk 'https://f-droid.org/repo/com.aurora.store_63.apk' && adb install ./aurora_store.apk && rm -f ./aurora_store.apk
fi

# TV Bro
if ! adb shell pm list packages | grep -q '^package:com.phlox.tvwebbrowser$'; then
    curl -o tv_bro.apk 'https://github.com/truefedex/tv-bro/releases/download/v2.0.1/tvbro-generic-2.0.1.armeabi-v7a.apk' && adb install ./tv_bro.apk && rm -f ./tv_bro.apk
fi

# SmartTube
if ! adb shell pm list packages | grep -q '^package:com.teamsmart.videomanager.tv'; then
    curl -o smarttube.apk -L 'https://kutt.it/stn_' && adb install ./smarttube.apk && rm -f ./smarttube.apk
fi
popd &>/dev/null

# My own customizations
# TODO: Check if these settings make a difference or not?
adb shell settings put global animator_duration_scale 0
adb shell settings put global development_settings_enabled 1
adb shell settings put global install_non_market_apps 1
adb shell settings put global transition_animation_scale 0
adb shell settings put global window_animation_scale 0
adb shell settings put secure ui_night_mode 2
adb shell settings put system screen_off_timeout 2147483647
