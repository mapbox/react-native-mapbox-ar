/**
 * Copyright (c) 2018-present, Mapbox.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import React from 'react';
import { View, Modal, FlatList, StyleSheet } from 'react-native';
import { Header, ListItem } from 'react-native-elements';
import { ViroARSceneNavigator } from 'react-viro';

import MapboxAR from '@mapbox/react-native-mapbox-ar';

import LandGrab from './src/examples/LandGrab';

const VIRO_API_KEY = 'AAAAC06D-F938-41A7-BCA5-A44F72ACEDD9';
const MAPBOX_ACCESS_TOKEN = 'pk.eyJ1Ijoibmlja2l0YWxpYW5vIiwiYSI6ImNqNzlia29wbTAwMzAycXF6bm55Mjlyc3UifQ.lob2IIX6ce6iaS206_hkJA';

MapboxAR.setAccessToken(MAPBOX_ACCESS_TOKEN);

class ExampleItem {
  constructor (label, SceneComponent) {
    this.label = label;
    this.SceneComponent = SceneComponent;
  }
}

const Examples = [
  new ExampleItem('Land Grab', LandGrab),
];

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  headerText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
});

class App extends React.Component {
  constructor (props) {
    super(props);

    this.state = {
      activeExample: -1,
    };

    this.renderItem = this.renderItem.bind(this);
    this.onBack = this.onBack.bind(this);
  }

  onBack () {
    this.setState({ activeExample: -1 });
  }

  onExamplePress (item, index) {
    this.setState({ activeExample: index });
  }

  renderItem ({ item, index }) {
    return (
      <ListItem
        title={item.label}
        onPress={() => this.onExamplePress(item, index)} />
    );
  }

  renderActiveARExample () {
    const isVisible = this.state.activeExample > -1;
    const activeExample = Examples[this.state.activeExample];

    const leftNavComponent = {
      icon: 'keyboard-backspace',
      color: 'white',
      onPress: this.onBack,
    };

    return (
      <Modal visible={isVisible} style={styles.container} onRequestClose={this.onBack} animationType='slide'>
        <Header
          leftComponent={leftNavComponent}
          centerComponent={{ text: activeExample && activeExample.label, style: styles.headerText }}
          style={{ position: 'absolute', top: 0, left: 0, right: 0 }} />

        {isVisible ? (
          <ViroARSceneNavigator
            style={styles.container}
            initialScene={{ scene: activeExample.SceneComponent }}
            apiKey={VIRO_API_KEY} />
        ) : null}
      </Modal>
    );
  }

  render () {
    return (
      <View style={styles.container}>
        <Header centerComponent={{ text: 'Mapbox AR', style: styles.headerText }} />

        <View style={styles.container}>
          <FlatList
            style={styles.exampleList}
            data={Examples}
            keyExtractor={(item) => item.label}
            renderItem={this.renderItem} />
        </View>

        {this.renderActiveARExample()}
      </View>
    );
  }
}

export default App;
