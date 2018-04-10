import React from 'react';

import {
  ViroText,
  ViroARPlaneSelector,
} from 'react-viro';

class Terrian extends React.Component {
  render () {
    return (
      <ViroARPlaneSelector>
        <ViroText text={'Hello World'} scale={[.5, .5, .5]} position={[0, 0, 0.5]} />
      </ViroARPlaneSelector>
    );
  }
}

export default Terrian;
