const easProjectId = process.env.EAS_BUILD_PROJECT_ID || process.env.EXPO_PROJECT_ID;

module.exports = {
  expo: {
    name: "wareefapp",
    slug: "wareefapp",
    owner: "hrhb",
    version: "0.1.0",
    orientation: "portrait",
    platforms: ["ios", "web"],
    ios: {
      bundleIdentifier: "sa.warif.app",
      buildNumber: "1",
      supportsTablet: false,
      infoPlist: {
        ITSAppUsesNonExemptEncryption: false
      }
    },
    extra: {
      eas: {
        projectId: easProjectId
      }
    }
  }
};
