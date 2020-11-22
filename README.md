# Tileable procedural textures
Collection of tileable procedural textures:
- value noise (with derivatives and gradient rotation)
- gradient noise (with derivatives)
- perlin noise (with gradient rotation)
- checkerboard (diagonal)
- patterns: tile weaves, cross, waves, stairs
- celullar noise
- metaballs (variant of cellular noise)
- voronoi (edges, cells)
- fbm (value, perlin, voronoi and derivative)
- domain warping (fbnm and gradient curl)

## Preview

[![shadertoy](screenshots/preview.png)](https://www.shadertoy.com/view/3sKXWh)

### Classic Noise

#### Random, Value Noise, Value Noise Derivatives and Grid Noise variant
![value-noise](screenshots/preview_value_noise.png)

#### Gradient Noise (Derivatives and configurable Disorder)
![gradient-noise](screenshots/preview_gradient_noise.png)

### Worley Noise

#### Cellular Noise (F1 and F2), Metaballs and Cellular Noise Derivatives
![cellular-noise](screenshots/preview_cellular.png)

#### Cellular Noise metrics (Manhattan, Chebyshev and Triangular)
![cellular-noise-metrics](screenshots/preview_cellular_metrics.png)

#### Voronoi (minimum edge distance, Cracks, random pattern and IDs)
![preview_voronoi](screenshots/preview_voronoi.png)

### FBM

### Domain warp

### Patterns

#### Checkerboard (plus 45 angle), Random Lines and Dots  
![preview_patterns_0](screenshots/preview_patterns_0.png)

#### Metaballs, Line Waves, Stairs and Cross Pattern
![preview_patterns_1](screenshots/preview_patterns_1.png)

#### Tile weaves with normal (Vesica and Capsule)
![preview_tile_weaves](screenshots/preview_tile_weaves.png)

## Contributing

Based on:
- [Filtering the checkerboard pattern by Inigo Quilez](https://www.iquilezles.org/www/articles/checkerfiltering/checkerfiltering.htm).
- [Value noise derivatives by Inigo Quilez](https://www.iquilezles.org/www/articles/morenoise/morenoise.htm).
- [Voronoi edges by Inigo Quilez](https://www.iquilezles.org/www/articles/voronoilines/voronoilines.htm).
- [2D distance functions by Inigo Quilez](https://www.iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm).
- [GPU Texture-Free Noise by Brian Sharpe](https://briansharpe.wordpress.com/2011/10/01/gpu-texture-free-noise/).
- [Modifications to Classic Perlin Noise by Brian Sharpe](https://briansharpe.wordpress.com/2012/03/09/modifications-to-classic-perlin-noise/).
- [Hash Functions for GPU Rendering by Mark Jarzynski](http://www.jcgt.org/published/0009/03/02/).

Bug reports and pull requests are welcome on GitHub at https://github.com/tuxalin/procedural-tileable-shaders.

## License

The code is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).