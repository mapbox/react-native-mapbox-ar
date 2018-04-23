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
        <ViroAmbientLight
         color='#ffffff' />
        <MapboxAR.Terrian />
      </ViroARScene>
    );
  }
}

export default LandGrab;
