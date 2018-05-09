import React from 'react';

import {
  ViroARScene,
  ViroAmbientLight,
  ViroDirectionalLight,
} from 'react-viro';

import MapboxAR from '@mapbox/react-native-mapbox-ar';

const PITCH_STATE = {
  START: 1,
  MOVE: 2,
  END: 3,
};

class LandGrab extends React.Component {
  constructor (props) {
    super(props);

    this.state = {
      scale: 2,
    };

    this.onPinch = this.onPinch.bind(this);
  }

  onPinch (pitchState, scaleFactor, source) {
    console.log('PINCH');

    if (pitchState === PITCH_STATE.MOVE) {
      this.setState({ scale: scaleFactor });
    }
  }

  render () {
    return (
      <ViroARScene dragType='FixedToWorld' onPinch={this.onPinch} onRotate={() => console.log('ROTATE')}>
        <ViroAmbientLight color='#ffffff' />

        <MapboxAR.Terrain
          draggable
          id='coolTerrain'
          sampleSize={6}
          scale={this.state.scale}
          bbox={[-112.49975, 36.36191, -112.457007, 36.388171]} />
      </ViroARScene>
    );
  }
}

export default LandGrab;
