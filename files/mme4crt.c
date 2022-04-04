/*
 * based on the mme4crt program from Ben Templeman
 * extended for use with rpi3b+
 * Please use for pi2scart and pi2jamma only
 * Author Jochen Zurborg
 * Date 08.11.2019
 * last modified 14.11.2019


**/
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>

long free_pixel_clock = 31270000;
int compute_dynamic_width(int width, int hmax, float freq);

int crt_rpi_switch(int width, int height, float hz, int crt_center_adjust, int mode, int superres);

int main(int argc, char **argv)
{


    if (argc != 7)
    {
        printf("Usage : mme4crt <width> <heigth> <freq> <shift> <superres> <mode>\n");
        printf("width      : width of game\n");
        printf("height     : heigth of game\n");
        printf("freq       : freq of game\n");
        printf("shift      : shift in x\n");
        printf("superres   : 1 (on) or 0 (off) for superres\n");
        printf("mode      :  0, 1, 2 for modes\n");
        printf(" mode = 0 write results in files retroarch_game.cfg, game_res.sh\n");
        printf(" mode = 1 write results in files for regamebox\n");
        printf(" mode = 2 execute timings directly\n");
        printf("mme4crt 320 224 60 30 1 1\n");
        printf("\n\nThis app is made for pi2scart and pi2jamma from www.arcadeforge.de only\n");
        
        return 0;
    }

    int w, h, shift, superres, mode = 0;
    float freq = 0;
    w = strtol(argv[1], NULL, 10);
    h = strtol(argv[2], NULL, 10);
    freq = strtof(argv[3], NULL);
    shift = strtol(argv[4], NULL, 10);
    superres = strtol(argv[5], NULL, 10);
    mode = strtol(argv[6], NULL, 10);



    printf ("width : %i\n", w);
    printf ("height : %i\n", h);
    printf ("freq : %f\n", freq);
    printf ("shift : %i\n", shift );
    printf ("super res : %i\n", superres);
    printf ("mode : %i\n", mode);


    if (superres >= 1) {
        // get hmax for super res
        //int htotal =crt_rpi_switch (w, h, freq, shift, 0, superres);
        //printf ("htotoal : %i\n", htotal);
        //int dyn_w = compute_dynamic_width (w, htotal, freq);
        //printf ("dynamic width : %i\n", dyn_w);
        // now set new res
        //Assume 2080

        crt_rpi_switch (1920, h, freq, shift, mode, superres);
    }
    else
        crt_rpi_switch (w, h, freq, shift, mode, superres);
}


int compute_dynamic_width(int width, int hmax, float freq)
{
    float i;
    int dynamic_width   = 0;
    //int min_height = 261;

    // bug rtype
    // rtype has 384 256 55
    // thus we have height total 296
    // using 261 lower value ends then in xres 2188
    // which cant be handled with rpi
    // so get hmax from hdmit_timings
    int min_height = hmax;

    long p_clock_test = 0;

    for (i = 0; i < 10; i=i+0.1)
    {
        dynamic_width = width * i;
        p_clock_test = dynamic_width * min_height * freq;
/*
        printf ("min_height : %i\n",min_height );
        printf ("freq : %i\n", freq);
        printf ("dynamic width : %i\n", dynamic_width);
        printf ("free p_clock : %i\n", free_pixel_clock);
        printf ("p_clock_test : %i\n", p_clock_test);

*/
        if (p_clock_test > free_pixel_clock)
            break;

    }
    return dynamic_width;
}

int crt_rpi_switch(int width, int height, float hz, int crt_center_adjust, int mode, int superres)
{

    char buffer[1024];
    static char output[250]             = {0};
    static char output1[250]            = {0};
    static char output2[250]            = {0};
    static char set_hdmi[250]           = {0};
    static char set_hdmi_timing[250]    = {0};
    int i              = 0;
    int hfp            = 0;
    int hsp            = 0;
    int hbp            = 0;
    int vfp            = 0;
    int vsp            = 0;
    int vbp            = 0;
    int hmax           = 0;
    int vmax           = 0;
    int pdefault       = 8;
    int pwidth         = 0;
    float roundw     = 0.0f;
    float roundh     = 0.0f;
    float pixel_clock  = 0;
    int ip_flag     = 0;
    int xoffset = crt_center_adjust;
    pid_t pid = fork();



    /* following code is the mode line generator */
    //hsp = (width * 0.117) - (xoffset*4);
    //printf("%i", xoffset);

    hsp = (width * 0.117);

    if (width < 700)
    {
        hfp    = (width * 0.065) - xoffset;
        hbp  = (width * 0.35-hsp-hfp) + xoffset;
    }
    else
    {
        hfp  = ((width * 0.033) + (width / 112)) - xoffset;
        hbp  = ((width * 0.225) + (width /58)) + xoffset;
    }

    if (superres == 1)
    {
        hfp  = ((width * 0.033) + (width / 112)) - xoffset;
        hbp  = ((width * 0.125) + (width / 58)) + xoffset;

    }
    // @Asche : check factors
    if (superres == 2)
    {
        hfp  = ((width * 0.033) + (width / 112)) - xoffset;
        hbp  = ((width * 0.150) + (width / 58)) + xoffset;

    }
    // @Asche : check factors
    if (superres == 3)
    {
        hfp  = ((width * 0.033) + (width / 112)) - xoffset;
        hbp  = ((width * 0.175) + (width / 58)) + xoffset;

    }
    // @Asche : check factors
    if (superres == 4)
    {
        hfp  = ((width * 0.033) + (width / 112)) - xoffset;
        hbp  = ((width * 0.200) + (width / 58)) + xoffset;

    }
    //hmax = hbp;

    if (height < 241)
        vmax = 261;
    //if (height < 241 && hz > 56 && hz < 58)
    if (height < 241 && hz > 55 && hz < 58)
        vmax = 280;
	if (height < 241 && hz > 56 && hz < 58)
        vmax = 282;
    if (height < 241 && hz < 55)
    {    //vmax = 313;
		// flying shark / twin cobra
        vmax = 286;
    }
    if (height > 250 && height < 260 && hz > 54)
        vmax = 296;
	if (height > 255 && height < 257 && hz > 54 && hz < 56)
	{	// r-type?
		vmax = 290;
	}
    if (height > 250 && height < 260 && hz > 52 && hz < 54)
        vmax = 285;
    if (height > 250 && height < 260 && hz < 52)
        vmax = 313;
    if (height > 260 && height < 300)
        vmax = 318;

    if (height > 400 && hz > 56)
        vmax = 533;
    if (height > 520 && hz < 57)
        vmax = 580;

    if (height > 300 && hz < 56)
         vmax = 615;
    if (height > 500 && hz < 56)
        vmax = 624;
    if (height > 300)
        pdefault = pdefault * 2;

    vfp = (height + ((vmax - height) / 2) - pdefault) - height;

    // no affect
    if (height < 300)
        vsp = vfp + 3; /* needs to be 3 for progressive */
    if (height > 300)
        vsp = vfp + 6; /* needs to be 6 for interlaced */

    vsp = 3;

    vbp = (vmax-height)-vsp-vfp;

    hmax = width+hfp+hsp+hbp;

    if (height < 300)
    {
        pixel_clock = (hmax * vmax * hz) ;
        ip_flag     = 0;
    }

    if (height > 300)
    {
        pixel_clock = (hmax * vmax * hz) /2 ;
        ip_flag     = 1;
    }
    /* above code is the modeline generator */

    if (pixel_clock < free_pixel_clock)
        if (pixel_clock < 5600000)
            pixel_clock = 4800000;
        else
            if (pixel_clock < 8000000)
                pixel_clock = 6400000;
            else
                if (pixel_clock < 14400000)
                    pixel_clock = 9600000;
                else
                    pixel_clock = 19200000;

    //write files
    if (mode == 0) 
    {

        snprintf(set_hdmi_timing, sizeof(set_hdmi_timing),
            "vcgencmd hdmi_timings %d 1 %d %d %d %d 1 %d %d %d 0 0 0 %.0f %d %.0f 1",
            width, hfp, hsp, hbp, height, vfp,vsp, vbp,
            hz, ip_flag, pixel_clock);

        FILE *f = fopen("timings.txt", "a");
        fprintf(f,"%s\n",set_hdmi_timing);
        fclose(f);

        printf("%s\n",set_hdmi_timing);


        FILE *file = fopen("retroarch_game.cfg", "w");
        fprintf(file,"custom_viewport_width = \"%i\"\n", width);
        fprintf(file,"custom_viewport_height = \"%i\"\n" , height);
        fprintf(file,"aspect_ratio_index = \"22\"\n");

        //fprintf(file,"video_rotation = \"0\"\n");

        fclose(file);

        FILE *res_script = fopen("game_res.sh", "w");
        fprintf(res_script,"%s\n",set_hdmi_timing);
        fprintf(res_script,"tvservice -e  \"DMT 87\" > /dev/null\n");
        fprintf(res_script,"sleep 0.3\n");
        fprintf(res_script,"fbset -depth 8 && fbset -depth 24\n");
        fprintf(res_script,"sleep 0.3\n");
        fclose(res_script);

    }


    //write regamebox files
    if (mode == 1) 
    {

        snprintf(set_hdmi_timing, sizeof(set_hdmi_timing),
            "vcgencmd hdmi_timings %d 1 %d %d %d %d 1 %d %d %d 0 0 0 %.0f %d %.0f 1",
            width, hfp, hsp, hbp, height, vfp,vsp, vbp,
            hz, ip_flag, pixel_clock);

        FILE *f = fopen("timings.txt", "a");
        fprintf(f,"%s\n",set_hdmi_timing);
        fclose(f);

        printf("%s\n",set_hdmi_timing);


        FILE *file = fopen("/root/resolution/game.cfg", "w");
        fprintf(file,"custom_viewport_width = \"%i\"\n", width);
        fprintf(file,"custom_viewport_height = \"%i\"\n" , height);

        // User know best what he want :))
        //fprintf(file,"custom_viewport_x = \"%s\"\n" , 0);
        //fprintf(file,"custom_viewport_y = \"%s\"\n" , 0);

        //fprintf(file,"video_scale_integer = \"false\"\n");


        fprintf(file,"aspect_ratio_index = \"22\"\n");


        //fprintf(file,"video_smooth = \"false\"\n");
        //fprintf(file,"video_threaded = \"false\"\n");
        //fprintf(file,"crop_overscan = \"false\"\n");

        //FIXME
        //fprintf(file,"video_rotation = \"%s\"\n" , (rotation));

        // vertical games on h screen 
        //fprintf(file,"video_rotation = \"0\"\n");

        fclose(file);


        FILE *res_script = fopen("/root/scripts/game_res.sh", "w");
        fprintf(res_script,"%s\n",set_hdmi_timing);
        fprintf(res_script,"tvservice -e  \"DMT 87\" > /dev/null\n");
        fprintf(res_script,"sleep 0.3\n");
        fprintf(res_script,"fbset -depth 8 && fbset -depth 24\n");
        fprintf(res_script,"sleep 0.3\n");
        fclose(res_script);

    }
    //execute hdmi_timings 
    if (mode == 2) 
    { 
        if (pid == 0) 
        {
            system(set_hdmi_timing);
            sleep(0.5);
            snprintf(output1,  sizeof(output1),
               "tvservice -e \"DMT 87\"");
            system(output1);

            sleep(0.3);
            snprintf(output2,  sizeof(output1),
              "fbset -g %d %d %d %d 32", width, height, width, height);
            system(output2);
            //snprintf(output2,  sizeof(output1),
            //   "fbset -depth 32");
            //system(output2);
            exit(0);
        }
    }
    return height + vfp + vsp + vbp;

}
