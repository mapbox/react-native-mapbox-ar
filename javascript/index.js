import { NativeModules } from 'react-native';

import locationManager from './modules/locationManager';

import Terrian from './components/Terrian';

let MapboxAR = { ...NativeModules.MapboxARModule };

// components
MapboxAR.World = null;
MapboxAR.Annotation = null;
MapboxAR.Terrian = Terrian;

// modules
MapboxAR.locationManager = null;

export default MapboxAR;
