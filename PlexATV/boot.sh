export APP_NAME="Lowtide.app"
export TARGET_DIR=/Applications/${APP_NAME}/Appliances/PLEX.frappliance

# To use: create ~/.MacOSX/environment.plist and set variable. Re-login to take effect.
if [ -z ${APPLETV_HOST} ]; then
    APPLETV_HOST=apple-tv.local
fi

# Copy local (in order to build the .deb
cp "${BUILT_PRODUCTS_DIR}/plex.frappliance/plex" "${BUILD_DIR}/../_deb/PLEX.frapplication/Applications/${APP_NAME}/Appliances/PLEX.frappliance/"


# Copy to the ATV
scp "${BUILT_PRODUCTS_DIR}/plex.frappliance/plex" root@${APPLETV_HOST}:${TARGET_DIR}
scp "${PROJECT_DIR}/_deb/PLEX.frapplication/Applications/${APP_NAME}/Appliances/PLEX.frappliance/Info.plist" root@${APPLETV_HOST}:${TARGET_DIR}

# Restart UI
ssh root@${APPLETV_HOST} 'killall AppleTV'
