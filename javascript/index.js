import { NativeModules } from 'react-native';

import locationManager from './modules/locationManager';

import Terrain from './components/Terrain';

let MapboxAR = { ...NativeModules.MapboxARModule };

// components
MapboxAR.World = null;
MapboxAR.Annotation = null;
MapboxAR.Terrain = Terrain;

// modules
MapboxAR.locationManager = null;

export default MapboxAR;
