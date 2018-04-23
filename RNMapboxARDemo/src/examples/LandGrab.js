import React from 'react';

import {
  ViroARScene,
  ViroAmbientLight,
  ViroDirectionalLight,
} from 'react-viro';

import MapboxAR from '@mapbox/react-native-mapbox-ar';

class LandGrab extends React.Component {
  render () {
    return (
      <ViroARScene>
        <ViroDirectionalLight
         color='#ffffff'
         castsShadow={true}
         shadowFarZ={200}
         shadowNearZ={200 * 0.25}
         shadowMapSize={256}
         shadowOpacity={0.2}
         direction={[0, -1, 0]} />
        <MapboxAR.Terrian />
      </ViroARScene>
    );
  }
}

export default LandGrab;
