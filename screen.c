/*  
 * screen.c - screen management
 *  
 * Copyright © 2007 Julien Danjou <julien@danjou.info> 
 * 
 * This program is free software; you can redistribute it and/or modify 
 * it under the terms of the GNU General Public License as published by 
 * the Free Software Foundation; either version 2 of the License, or 
 * (at your option) any later version. 
 * 
 * This program is distributed in the hope that it will be useful, 
 * but WITHOUT ANY WARRANTY; without even the implied warranty of 
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 * GNU General Public License for more details. 
 * 
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA. 
 * 
 */

#include "util.h"
#include "screen.h"
#include "tag.h"
#include "layout.h"

extern Client *sel, *clients;

/** Get screens info
 * \param disp Display ref
 * \param screen Screen number
 * \param statusbar statusbar
 * \param screen_number int pointer filled with number of screens
 * \return ScreenInfo struct array with all screens info
 */
ScreenInfo *
get_screen_info(Display *disp, int screen, Statusbar statusbar, int *screen_number)
{
    int i, fake_screen_number = 0;
    ScreenInfo *si;

    if(XineramaIsActive(disp))
    {
        si = XineramaQueryScreens(disp, screen_number);
        fake_screen_number = *screen_number;
    }
    else
    {
        /* emulate Xinerama info but only fill the screen we want */
        *screen_number =  1;
        si = p_new(ScreenInfo, screen + 1);
        si[screen].width = DisplayWidth(disp, screen);
        si[screen].height = DisplayHeight(disp, screen);
        si[screen].x_org = 0;
        si[screen].y_org = 0;
        fake_screen_number = screen + 1;
    }

    for(i = 0; i < fake_screen_number; i++)
    {
        if(statusbar.position == BarTop 
           || statusbar.position == BarBot)
            si[i].height -= statusbar.height;
        if(statusbar.position == BarTop)
            si[i].y_org += statusbar.height;
    }
    
    return si;
}

/** Get display info
 * \param disp Display ref
 * \param screen Screen number
 * \param statusbar the statusbar
 * \return ScreenInfo struct pointer with all display info
 */
ScreenInfo *
get_display_info(Display *disp, int screen, Statusbar statusbar)
{
    ScreenInfo *si;

    si = p_new(ScreenInfo, 1);

    si->x_org = 0;
    si->y_org = statusbar.position == BarTop ? statusbar.height : 0;
    si->width = DisplayWidth(disp, screen);
    si->height = DisplayHeight(disp, screen) -
        ((statusbar.position == BarTop || statusbar.position == BarBot) ? statusbar.height : 0);

    return si;
}

void
uicb_focusnextscreen(Display *disp,
                     DC *drawcontext,
                     awesome_config * awesomeconf,
                     const char *arg __attribute__ ((unused)))
{
    Client *c;
    int next_screen = awesomeconf->screen + 1 >= ScreenCount(disp) ? 0 : awesomeconf->screen + 1;

    for(c = clients; c && !isvisible(c, next_screen, awesomeconf[next_screen - awesomeconf->screen].tags, awesomeconf[next_screen - awesomeconf->screen].ntags); c = c->next);
    if(c)
    {
        focus(c->display, &drawcontext[next_screen - awesomeconf->screen], c, True, &awesomeconf[next_screen - awesomeconf->screen]);
        restack(c->display, &drawcontext[next_screen - awesomeconf->screen], &awesomeconf[next_screen - awesomeconf->screen]);
    }
}

void
uicb_focusprevscreen(Display *disp,
                     DC *drawcontext,
                     awesome_config * awesomeconf,
                     const char *arg __attribute__ ((unused)))
{
    Client *c;
    int prev_screen = awesomeconf->screen - 1 < 0 ? ScreenCount(disp) - 1 : awesomeconf->screen - 1;

    for(c = clients; c && !isvisible(c, prev_screen, awesomeconf[prev_screen - awesomeconf->screen].tags, awesomeconf[prev_screen - awesomeconf->screen].ntags); c = c->next);
    if(c)
    {
        focus(c->display, &drawcontext[prev_screen - awesomeconf->screen], c, True, &awesomeconf[prev_screen - awesomeconf->screen]);
        restack(c->display, &drawcontext[prev_screen - awesomeconf->screen], &awesomeconf[prev_screen - awesomeconf->screen]);
    }
}
