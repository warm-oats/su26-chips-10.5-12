import * as d3 from 'd3';
import * as stateMapUtils from './state_map_utils';

$(() => {
  const stateMap = stateMapUtils.StateMap();
  d3.json(stateMap.topojsonUrl).then((topology) => {
    const mapAssets = stateMapUtils.parseTopojson(stateMap, topology);
    stateMap.svgElement.selectAll('path')
      .data(mapAssets.geojson.features)
      .enter()
      .append('path')
      .attr('class', 'actionmap-view-region')
      .attr('tabindex', 0)
      .attr('role', 'link')
      .attr('aria-label', (d) => stateMapUtils.countyName(stateMap, d))
      .attr('data-county-name', (d) => stateMapUtils.countyName(stateMap, d))
      .attr('data-county-fips-code', (d) => d.properties.COUNTYFP)
      .attr('data-search-url', (d) => stateMapUtils.countySearchUrl(stateMap, d))
      .attr('d', mapAssets.path);

    stateMapUtils.setupEventHandlers(stateMap);
  });
});
