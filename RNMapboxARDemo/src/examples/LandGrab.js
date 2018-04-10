import React from 'react';

import {
  ViroARScene,
  ViroARPlaneSelector,
  ViroText,
} from 'react-viro';

import MapboxAR from '@mapbox/react-native-mapbox-ar';

class LandGrab extends React.Component {
  render () {
    return (
      <ViroARScene>
        <MapboxAR.Terrian />
      </ViroARScene>
    );
  }
}

export default LandGrab;
