PImage oimg; // orignial img
PImage gimg; // target img
PImage himg;

void setup() {
  oimg = loadImage("image0000.tif");
  gimg = createImage(oimg.width, oimg.height, RGB); // gray scaled
  himg = createImage(oimg.width, oimg.height, RGB); // equalised
  
  size(1136, 320); // display gray & equalised img at the same time

  // convert the img to gray scale at first
  //for (int y = 0; y < oimg.height - 1; y++)
  //  for (int x = 0; x < oimg.width - 1; x++){
  //    int loc = y * oimg.width + x;
  //    color c = oimg.pixels[loc];
  //    int greyValue = (int)(0.212671 * red(c) + 0.715160 * green(c) 
  //                                      + 0.072169 * blue(c));
  //    color greyColor = color(greyValue);
  //    gimg.pixels[loc] = greyColor;      
  //  }

  int [][] histg = new int [3][256];

  // get the distribution
  for(int cindex = 0; cindex < 3; cindex++){
    for (int y = 0; y < oimg.height; y++)
      for (int x = 0; x < oimg.width; x++){
        int loc = y * gimg.width + x;
        color c = gimg.pixels[loc];
        int greyValue = (int) red(c);
        if (cindex == 0){
         greyValue = (int) red(c); 
        }
        else if (cindex == 1){
         greyValue = (int) green(c); 
        }
        else if (cindex == 2){
         greyValue = (int) blue(c); 
        }

        histg[cindex][greyValue]++;
      }
  }
    
  int [][] cdf = new int [3][256];
  
  int [][] h = new int [3][256];
  
  for(int cindex = 0; cindex < 3; cindex++){
    int cdfmin = histg[cindex][0];
    cdf[cindex][0] = histg[cindex][0];
    for (int i = 1; i < histg.length; i++){
      cdf[cindex][i] = cdf[cindex][i - 1] + histg[cindex][i];
    }
    
    // ** Key thing: caculate the new value for each gray scale
    for (int i = 0; i < histg.length; i++){
      h[cindex][i] = (int)((float)(cdf[cindex][i] - cdfmin) * 255 / 
                    (float)(oimg.width * oimg.height - cdfmin));
    }
  }
  
  // modify the original image to equalised image
  // get the histogram
  for(int cindex = 0; cindex < 3; cindex++){
    for (int y = 0; y < oimg.height; y++)
      for (int x = 0; x < oimg.width; x++){
        int loc = y * oimg.width + x;
        color c = gimg.pixels[loc];
        int grayValuer = (int) red(c);
        int grayValueg = (int) green(c);
        int grayValueb = (int) blue(c);
        himg.pixels[loc] = color(h[0][grayValuer], h[1][grayValueg], h[2][grayValueb] );      
      } 
  }
  
}

void draw(){
  image(oimg, 0, 0);
  image(himg, oimg.width, 0);
  save("equalised.jpg");
}