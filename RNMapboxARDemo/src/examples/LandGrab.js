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
      scale: 0.005,
    };

    this.onPinch = this.onPinch.bind(this);

    this.yosemite = this.yosemite.bind(this);
    this.squaw = this.squaw.bind(this);
    this.tahoe = this.tahoe.bind(this);
    this.kauai = this.kauai.bind(this);
    this.spa = this.spa.bind(this);
    this.nurburgring = this.nurburgring.bind(this);
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
          sampleSize={3}
          scale={this.state.scale}
          bbox={this.yosemite()} />
      </ViroARScene>
    );
  }

  yosemite () {
    return [-119.667111,37.682308,-119.489696,37.786133];
  }

  squaw () {
    return [-120.298941,39.172602,-120.196572,39.222229];
  }

  tahoe () {
    return [-120.229716,38.878172,-119.769107,39.286996];
  }

  kauai () {
    return [-159.796592,21.85586,-159.283945,22.248503];
  }

  spa () {
    return [5.954657,50.426648,5.981694,50.447548];
  }

  nurburgring () {
    return [6.916266,50.322067,7.007493,50.382967];
  }
}

export default LandGrab;
