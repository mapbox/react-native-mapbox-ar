import React from 'react';
import { NativeModules } from 'react-native';

import {
  ViroNode,
  Viro3DObject,
  ViroARPlaneSelector,
  ViroMaterials,
  ViroAnimations,
} from 'react-viro';

const MapboxAR = NativeModules.MapboxARModule;

ViroAnimations.registerAnimations({
  rotateX: { properties: { rotateX:"+=45" }, duration:1000 },
});

class Terrian extends React.Component {
  constructor (props) {
    super(props);

    MapboxAR.assertAccessToken();

    this.state = {
      objURI: '',
    };

    this._isMounted = false;
  }

  componentWillMount () {
    this._isMounted = true;

    if (this.props.onGenerationStart) {
      this.props.onGenerationStart();
    }

    MapboxAR.getTerrianObjectUri().then((res) => {
      if (this._isMounted) {
        ViroMaterials.createMaterials({
          now: {
             lightingModel: 'Lambert',
             diffuseTexture: { uri: 'https://api.mapbox.com/v4/mapbox.satellite/8/44/98.png?access_token=pk.eyJ1Ijoibmlja2l0YWxpYW5vIiwiYSI6ImNqNzlia29wbTAwMzAycXF6bm55Mjlyc3UifQ.lob2IIX6ce6iaS206_hkJA' },
           },
        });

        this.setState({ objURI: res.objFileURI });

        if (this.props.onGenerationEnd) {
          this.props.onGenerationEnd(res.objFileURI, res.tileFileURI);
        }
      }
    });
  }

  componentWillUnmount () {
    this._isMounted = false;
  }

  onRotate (rotationState, rotationFactor, source) {

  }

  render () {
    if (!this.state.objURI) {
      return null;
    }
    return (
      <ViroARPlaneSelector>
        <ViroNode rotation={[-90, 0, 0]} position={[0, -128, -128]}>
          <Viro3DObject
              type='OBJ'
              ref={c => this._c = c}
              source={{ uri: this.state.objURI }}
              materials={['now']} />
        </ViroNode>
      </ViroARPlaneSelector>
    );
  }
}

export default Terrian;
