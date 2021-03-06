#include <stdlib.h>
static double _EPSILON_NORM_ = 0.0000005;
/*
 * epsilon value to decide of the interpolation type.
 * If one derivative's absolute value is larger than this
 * epsilon (close to one), then we use the nearest value
 * else we perform a [bi,tri]linear interpolation.
 */
static double _EPSILON_DERIVATIVE_ = 0.9995;

void Remove_Gradient_NonMaxima_Slice_2D( float *maxima,
					 float *gx,
					 float *gy,
					 float *norme,
					 int Lx,
					 int Ly)
{
  /* 
   * the buffer norme[0] contains the gradient modulus of the 
   * previous slice, the buffer norme[1] the ones of the
   * slice under study, while norme[2] containes the ones
   * of the next slice.
   */
  /*
   * dimensions
   */
  int dimx = Lx;
  int dimy = Ly;
  int dimxMinusOne = dimx - 1;
  int dimxPlusOne = dimx + 1;
  int dimyMinusOne = dimy - 1;
  /* 
   * pointers
   */
  register float *fl_pt1 = (float*)NULL;
  register float *fl_pt2 = (float*)NULL;
  register float *fl_max = (float*)NULL;
  register float *fl_nor = (float*)NULL;
  register float *fl_upper_left = (float*)NULL;
  /*
   * coordinates and vector's components
   */
  register int x, y;
  register double normalized_gx;
  register double normalized_gy;
  register double x_point_to_be_interpolated;
  register double y_point_to_be_interpolated;
  int x_upper_left_corner;
  int y_upper_left_corner;
  /*
   * coefficients
   */ 
  register double dx, dy, dxdy;
  double c00, c01, c10, c11;
  /*
   * modulus
   */
  double interpolated_norme;

  /*
   * we set the image border to zero.
   * First the borders along X direction,
   * second, the borders along the Y direction.
   */
  fl_pt1 = maxima;
  fl_pt2 = maxima + (dimy-1)*dimx;
  for (x=0; x<dimx; x++, fl_pt1++, fl_pt2++ )
    *fl_pt1 = *fl_pt2 = 0.0;
  fl_pt1 = maxima + dimx;
  fl_pt2 = maxima + dimx + dimx - 1;
  for (y=1; y<dimy-1; y++, fl_pt1+=dimx, fl_pt2+=dimx )
    *fl_pt1 = *fl_pt2 = 0.0;
  
  /*
   * We investigate the middle of the image.
   */
  /* 
   * Pointers are set to the first point
   * to be processed.
   */
  fl_max = maxima + dimx + 1;
  fl_pt1 = gx + dimx + 1;
  fl_pt2 = gy + dimx + 1;
  fl_nor = norme + dimx + 1;
  for ( y=1; y<dimyMinusOne; y++, fl_max+=2, fl_pt1+=2, fl_pt2+=2, fl_nor+=2 )
    for ( x=1; x<dimxMinusOne; x++, fl_max++,  fl_pt1++,  fl_pt2++,  fl_nor++ ) {
      /*
       * If the modulus is too small, go to the next point.
       */
      if ( *fl_nor < _EPSILON_NORM_ ) {
	*fl_max = 0.0;
	continue;
      }
      /*
       * We normalize the vector gradient.
       */
      normalized_gx = *fl_pt1 / *fl_nor;
      normalized_gy = *fl_pt2 / *fl_nor;
      
      /*
       * May we use the nearest value?
       */
      if ( (-normalized_gx > _EPSILON_DERIVATIVE_) ||
	   (normalized_gx > _EPSILON_DERIVATIVE_) ||
	   (-normalized_gy > _EPSILON_DERIVATIVE_) ||
	   (normalized_gy > _EPSILON_DERIVATIVE_) ) {
	/*
	 * First point to be interpolated.
	 */
	x_upper_left_corner = (int)( (double)x + normalized_gx + 0.5 );
	y_upper_left_corner = (int)( (double)y + normalized_gy + 0.5 );
	interpolated_norme = *(norme + (x_upper_left_corner + y_upper_left_corner * dimx));
	if ( *fl_nor <= interpolated_norme ) {
	  *fl_max = 0.0;
	  continue;
	}
	/*
	 * Second point to be interpolated.
	 */
	x_upper_left_corner = (int)( (double)x - normalized_gx + 0.5 );
	y_upper_left_corner = (int)( (double)y - normalized_gy + 0.5 );
	interpolated_norme = *(norme + (x_upper_left_corner + y_upper_left_corner * dimx));
	if ( *fl_nor < interpolated_norme ) {
	  *fl_max = 0.0;
	  continue;
	}
	/*
	 * We found a gradient extrema.
	 */
	*fl_max = *fl_nor;
	continue;
      }
    
      
      /*
       * From here we perform a bilinear interpolation
       */

      /*
       * First point to be interpolated.
       * It is the current point + an unitary vector
       * in the direction of the gradient.
       * It must be inside the image.
       */
      x_point_to_be_interpolated = (double)x + normalized_gx;
      y_point_to_be_interpolated = (double)y + normalized_gy;
      if ( (x_point_to_be_interpolated < 0.0) ||
	   (x_point_to_be_interpolated >= dimxMinusOne) ||
	   (y_point_to_be_interpolated < 0.0) ||
	   (y_point_to_be_interpolated >= dimyMinusOne) ) {
	*fl_max = 0.0;
	continue;
      }
      /* 
       * Upper left corner,
       * coordinates of the point to be interpolated
       * with respect to this corner.
       */
      x_upper_left_corner = (int)x_point_to_be_interpolated;
      y_upper_left_corner = (int)y_point_to_be_interpolated;
      dx = x_point_to_be_interpolated - (double)x_upper_left_corner;
      dy = y_point_to_be_interpolated - (double)y_upper_left_corner;
      dxdy = dx * dy;
      /* 
       * bilinear interpolation of the gradient modulus 
       * norme[x_point_to_be_interpolated, y_point_to_be_interpolated] =
       *   norme[0,0] * ( 1 - dx) * ( 1 - dy ) +
       *   norme[1,0] * ( dx ) * ( 1 - dy ) +
       *   norme[0,1] * ( 1 - dx ) * ( dy ) +
       *   norme[1,1] * ( dx ) * ( dy )
       */
      c00 = 1.0 - dx - dy + dxdy;
      c10 = dx - dxdy;
      c01 = dy - dxdy;
      c11 = dxdy;
      fl_upper_left = norme + (x_upper_left_corner + y_upper_left_corner * dimx);
      interpolated_norme = *(fl_upper_left) * c00 +
	*(fl_upper_left + 1) * c10 +
	*(fl_upper_left + dimx) * c01 +
	*(fl_upper_left + dimxPlusOne) * c11;
      /*
       * We compare the modulus of the point with the
       * interpolated modulus. It must be larger to be
       * still considered as a potential gradient extrema.
       *
       * Here, we consider that it is strictly superior.
       * The next comparison will be superior or equal.
       * This way, the extrema is in the light part of the
       * image. 
       * By inverting both tests, we can put it in the
       * dark side of the image.
       */
      if ( *fl_nor <= interpolated_norme ) {
	*fl_max = 0.0;
	continue;
      }
      /*
       * Second point to be interpolated.
       * It is the current point - an unitary vector
       * in the direction of the gradient.
       * It must be inside the image.
       */
      x_point_to_be_interpolated = (double)x - normalized_gx;
      y_point_to_be_interpolated = (double)y - normalized_gy;
      if ( (x_point_to_be_interpolated < 0.0) ||
	   (x_point_to_be_interpolated >= dimxMinusOne) ||
	   (y_point_to_be_interpolated < 0.0) ||
	   (y_point_to_be_interpolated >= dimyMinusOne) ) {
	*fl_max = 0.0;
	continue;
      }
      /* 
       * Upper left corner.
       */
      x_upper_left_corner = (int)x_point_to_be_interpolated;
      y_upper_left_corner = (int)y_point_to_be_interpolated;
      /* we do not recompute the coefficients
	 dx = x_point_to_be_interpolated - (double)x_upper_left_corner;
	 dy = y_point_to_be_interpolated - (double)y_upper_left_corner;
	 dxdy = dx * dy;
      */
      /*
       * We may use the previous coefficients.
       * norme[x_point_to_be_interpolated, y_point_to_be_interpolated] =
       *   norme[0,0] * c11 +
       *   norme[1,0] * c01 +
       *   norme[0,1] * c10 +
       *   norme[1,1] * c00
       *
       * WARNING: it works only if the cases where one derivative is close
       *          to -/+ 1 are already be independently processed, else
       *          it may lead to errors.
       */
      /* we do not recompute the coefficients
	 c00 = 1.0 - dx - dy + dxdy;
	 c10 = dx - dxdy;
	 c01 = dy - dxdy;
	 c11 = dxdy;
	 fl_upper_left = norme + (x_upper_left_corner + y_upper_left_corner * dimx);
	 interpolated_norme = *(fl_upper_left) * c00 +
	 *(fl_upper_left + 1) * c10 +
	 *(fl_upper_left + dimx) * c01 +
	 *(fl_upper_left + dimxPlusOne) * c11;
	 */
      fl_upper_left = norme + (x_upper_left_corner + y_upper_left_corner * dimx);
      interpolated_norme = *(fl_upper_left) * c11 +
	*(fl_upper_left + 1) * c01 +
	*(fl_upper_left + dimx) * c10 +
	*(fl_upper_left + dimxPlusOne) * c00;
      /*
       * Last test to decide whether or not we 
       * have an extrema
       */
      if ( *fl_nor < interpolated_norme ) {
	*fl_max = 0.0;
	continue;
      }
      /*
       * We found a gradient extrema.
       */
      *fl_max = *fl_nor;
    }
}
