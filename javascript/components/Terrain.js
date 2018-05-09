import React from 'react';
import PropTypes from 'prop-types';
import { NativeModules } from 'react-native';

import cover from '@mapbox/tile-cover';
import SphericalMercator from '@mapbox/sphericalmercator';

import makeBboxPolygon from '@turf/bbox-polygon';

import {
  point as makePoint,
  polygon as makePolygon,
} from '@turf/helpers';

import getMidpoint from '@turf/midpoint';
import makeBBox from '@turf/bbox';

import {
  ViroNode,
  Viro3DObject,
  ViroARPlaneSelector,
  ViroMaterials,
  ViroAnimations,
} from 'react-viro';

const MapboxAR = NativeModules.MapboxARModule;
const MapboxARTerrain = NativeModules.MapboxARTerrainModule;

const DOUBLE_THRESHOLD = 640;
const CORNER_TILE_ZOOM = 22;
const TILE_SIZE = 256;
const BASE_RGB_TILE_URI = 'https://api.mapbox.com/v4/mapbox.terrain-rgb';
const BASE_SATELLITE_TILE_URI = 'https://api.mapbox.com/v4/mapbox.satellite';

const sphericalMercator = new SphericalMercator({ size: TILE_SIZE });

ViroMaterials.createMaterials({
  mapboxTerrainDarkenWall: {
    lightingModel: 'Lambert',
    diffuseColor: 'rgba(0, 0, 0, 0.84)',
  },
});

class Terrain extends React.Component {
  static MaterialTypeSatellite = 'satellite';
  static MaterialTypeSolid = 'solid';
  static MaterialTypeCustom = 'custom';

  static propTypes = {
    id: PropTypes.string.isRequired,

    type: PropTypes.oneOf([
      'satellite',
      'solid',
      'custom',
    ]),

    draggable: PropTypes.bool,

    materialName: PropTypes.string,

    bbox: PropTypes.arrayOf(PropTypes.number).isRequired,

    color: PropTypes.string,

    heightModifier: PropTypes.number,

    sampleSize: PropTypes.number,

    scale: PropTypes.number,

    onCreateStart: PropTypes.func,

    onCreateEnd: PropTypes.func,
  };

  static defaultProps = {
    color: 'rgba(0, 0, 0, 1)',
    type: 'satellite',
    heightModifier: 1.0,
    sampleSize: 6,
    scale: 2,
  };

  constructor (props) {
    super(props);

    MapboxAR.assertAccessToken();

    this.state = {
      objURI: '',
      wallURI: '',
    };

    this._isMounted = false;
  }

  get satelliteMaterialName () {
    return `${this.props.id}-satellite`;
  }

  get solidMaterialName () {
    return `${this.props.id}-solid`;
  }

  get materials () {
    const materials = [];

    if (this.props.type === Terrain.MaterialTypeSatellite) {
      materials.push(this.satelliteMaterialName);
    } else if (this.props.type === Terrain.MaterialTypeCustom) {
      materials.push(this.props.materialName);
    } else {
      materials.push(this.solidMaterialName);
    }

    return materials;
  }

  componentWillMount () {
    this._isMounted = true;
    this._identifyTiles();
  }

  componentWillUnmount () {
    this._isMounted = false;
  }

  _identifyTiles () {
    const nwPolygon = this._convertBboxToNWPolygon();

    // TODO: check to make sure polygon is not too small or too big

    const corners = [
      nwPolygon.geometry.coordinates[0][2], // se
      nwPolygon.geometry.coordinates[0][0], // nw
    ];

    const cornerTiles = corners.map((corner) => {
      return cover.tiles(makePoint(corner).geometry, {
        min_zoom: CORNER_TILE_ZOOM,
        max_zoom: CORNER_TILE_ZOOM,
      })[0];
    });

    const tileExtent = cornerTiles[0].map((d, i) => d - cornerTiles[1][i]);
    const base = Math.log(Math.abs(Math.max.apply(Math, tileExtent))) / Math.log(2);
    const zoomLevel = Math.floor(22 - base + 0.5);

    if (!this._isValidZoomLevel(zoomLevel)) {
      throw new Error('Zoom level is not finite number, try increasing the size of your bounding box');
    }

    const tiles = cover.tiles(nwPolygon.geometry, {
      min_zoom: zoomLevel,
      max_zoom: zoomLevel,
    });

    const upperLeft = sphericalMercator.px(corners[1], zoomLevel);
    const lowerRight = sphericalMercator.px(corners[0], zoomLevel);

    const upperLeftTileBox = sphericalMercator.bbox(
      Math.floor(upperLeft[0] / TILE_SIZE),
      Math.floor(upperLeft[1] / TILE_SIZE),
      zoomLevel,
    );

    const upperRight = sphericalMercator.px([
      upperLeftTileBox[0],
      upperLeftTileBox[3],
    ], zoomLevel);

    const offsets = [
      upperLeft[0] - upperRight[0],
      upperLeft[1] - upperRight[1],
    ];

    const upperLeftTile = upperLeft.map((px) => Math.floor(px / TILE_SIZE));

    const height = Math.abs(lowerRight[1] - upperLeft[1]);
    const width = Math.abs(lowerRight[0] - upperLeft[0]);

    const tilesToLoad = tiles.map((tile, index) => {
      return {
        url: `${BASE_RGB_TILE_URI}/${tile[2]}/${tile[0]}/${tile[1]}.pngraw?access_token={ACCESS_TOKEN}`,
        px: (tile[0] - upperLeftTile[0]) * TILE_SIZE - offsets[0],
        py: (tile[1] - upperLeftTile[1]) * TILE_SIZE - offsets[1],
      };
    });

    const satelliteURI = this._getSatelliteTileURI(corners, width, height, zoomLevel);
    this._createTerrain(width, height, zoomLevel, tilesToLoad, satelliteURI);
  }

  _createTerrain (width, height, zoom, tilesToLoad, satelliteURI) {
    if (this.props.onCreateStart) {
      this.props.onCreateStart();
    }

    let terrainOptions = {
      width: width,
      height: height,
      zoom: zoom,
      tiles: tilesToLoad,
      satelliteURI: satelliteURI,
      sampleSize: this.props.sampleSize,
      heightModifier: this.props.heightModifier,
    };

    MapboxARTerrain.createMesh(terrainOptions).then((res) => {
      if (this._isMounted) {
        const materials = {
          [this.satelliteMaterialName]: {
            lightingModel: 'Lambert',
            diffuseTexture: { uri: res.satelliteFileURI },
          },
          [this.solidMaterialName]: {
            lightingModel: 'Lambert',
            diffuseTexture: { uri: res.satelliteFileURI },
          }
        };
        ViroMaterials.createMaterials(materials);

        this.setState({ objURI: res.objFileURI, wallURI: res.wallFileURI });

        if (this.props.onCreateEnd) {
          this.props.onCreateEnd();
        }
      }
    });
  }

  _getSatelliteTileURI (corners, width, height, zoom) {
    // get center point between nw and se corners
    const centerCoord = getMidpoint(
      makePoint(corners[1]), // nw point
      makePoint(corners[0]), // se point
    ).geometry.coordinates;

    const canBeDoubled = width < DOUBLE_THRESHOLD && height < DOUBLE_THRESHOLD;
    const bumpZoom = canBeDoubled ? 2 : 1;

    return `${BASE_SATELLITE_TILE_URI}/${centerCoord},${zoom + bumpZoom}/${width * 2}x${height * 2}@2x.png?access_token={ACCESS_TOKEN}`;
  }

  _isValidZoomLevel (zoomLevel) {
    if (isNaN(zoomLevel)) {
      return false;
    }
    return zoomLevel !== Infinity && zoomLevel !== -Infinity && zoomLevel > 0;
  }

  _convertBboxToNWPolygon () {
    // turf calculates bbox polygons as [sw, se, ne, nw, sw]
    const swPolygon = makeBboxPolygon(this.props.bbox);
    const sw = swPolygon.geometry.coordinates[0][0];
    const se = swPolygon.geometry.coordinates[0][1];
    const ne = swPolygon.geometry.coordinates[0][2];
    const nw = swPolygon.geometry.coordinates[0][3];

    // rearrange coordinates to start at north west corner and traverse clockwise
    return makePolygon([[nw, ne, se, sw, nw]]);
  }

  renderObjects () {
    const items = [];

    // elevation model
    items.push(
      <Viro3DObject
        key='mapbox-elevation'
        type='OBJ'
        rotation={[-90, 0, 0]}
        scale={[this.props.scale, this.props.scale, this.props.scale]}
        source={{ uri: this.state.objURI }}
        materials={this.materials} />
    );

    // wall model
    items.push(
      <Viro3DObject
          key='mapbox-elevation-wall'
          type='OBJ'
          ref={c => this._c = c}
          rotation={[-90, 0, 0]}
          scale={[this.props.scale, this.props.scale, this.props.scale]}
          source={{ uri: this.state.wallURI }}
          materials={this.materials} />
    );

    // add darken wall texture
    if (this.props.type === Terrain.MaterialTypeSatellite) {
      items.push(
        <Viro3DObject
          key='mapbox-elevation-darken-wall'
          type='OBJ'
          ref={c => this._c = c}
          rotation={[-90, 0, 0]}
          scale={[this.props.scale, this.props.scale, this.props.scale]}
          source={{ uri: this.state.wallURI }}
          materials={['mapboxTerrainDarkenWall']} />
      );
    }

    return items;
  }

  render () {
    if (!this.state.objURI) {
      return null;
    }

    const nodeProps = {
      dragType: this.props.draggable ? 'FixedToWorld' : undefined,
      rotation: [0, 0, 0],
      position: [0, -TILE_SIZE / this.props.sampleSize, -TILE_SIZE / this.props.sampleSize],
    };

    return (
      <ViroNode {...nodeProps}>
        {this.renderObjects()}
      </ViroNode>
    );
  }
}

export default Terrain;
