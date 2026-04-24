/***************************************************************************
 *                              RasMol 2.7.5                               *
 *                                                                         *
 *                                 RasMol                                  *
 *                 Molecular Graphics Visualisation Tool                   *
 *                              13 June 2009                               *
 *                                                                         *
 *                   Based on RasMol 2.6 by Roger Sayle                    *
 * Biomolecular Structures Group, Glaxo Wellcome Research & Development,   *
 *                      Stevenage, Hertfordshire, UK                       *
 *         Version 2.6, August 1995, Version 2.6.4, December 1998          *
 *                   Copyright (C) Roger Sayle 1992-1999                   *
 *                                                                         *
 *                          and Based on Mods by                           *
 *Author             Version, Date             Copyright                   *
 *Arne Mueller       RasMol 2.6x1   May 98     (C) Arne Mueller 1998       *
 *Gary Grossman and  RasMol 2.5-ucb Nov 95     (C) UC Regents/ModularCHEM  *
 *Marco Molinaro     RasMol 2.6-ucb Nov 96         Consortium 1995, 1996   *
 *                                                                         *
 *Philippe Valadon   RasTop 1.3     Aug 00     (C) Philippe Valadon 2000   *
 *                                                                         *
 *Herbert J.         RasMol 2.7.0   Mar 99     (C) Herbert J. Bernstein    * 
 *Bernstein          RasMol 2.7.1   Jun 99         1998-2008               *
 *                   RasMol 2.7.1.1 Jan 01                                 *
 *                   RasMol 2.7.2   Aug 00                                 *
 *                   RasMol 2.7.2.1 Apr 01                                 *
 *                   RasMol 2.7.2.1.1 Jan 04                               *
 *                   RasMol 2.7.3   Feb 05                                 *
 *                   RasMol 2.7.3.1 Apr 06                                 *
 *                   RasMol 2.7.4   Nov 07                                 *
 *                   RasMol 2.7.4.1 Jan 08                                 *
 *                   RasMol 2.7.4.2 Mar 08                                 *
 *                   RasMol 2.7.5   May 09                                 *
 *                                                                         *
 * RasMol 2.7.5 incorporates changes by T. Ikonen, G. McQuillan, N. Darakev*
 * and L. Andrews (via the neartree package).  Work on RasMol 2.7.5        *
 * supported in part by grant 1R15GM078077-01 from the National Institute  *
 * of General Medical Sciences (NIGMS), U.S. National Institutes of Health *
 * and by grant ER63601-1021466-0009501 from the Office of Biological &    *
 * Environmental Research (BER), Office of Science, U. S. Department of    *
 * Energy.  RasMol 2.7.4 incorporated  changes by G. Todorov, Nan Jia,     *
 * N. Darakev, P. Kamburov, G. McQuillan, and J. Jemilawon. Work on RasMol *
 * 2.7.4 supported in part by grant 1R15GM078077-01 from the NIGMS/NIH and *
 * grant ER63601-1021466-0009501 from BER/DOE.  RasMol 2.7.3 incorporates  *
 * changes by Clarice Chigbo, Ricky Chachra, and Mamoru Yamanishi.  Work   *
 * on RasMol 2.7.3 supported in part by grants DBI-0203064, DBI-0315281    *
 * and EF-0312612 from the U.S. National Science Foundation and grant      *
 * DE-FG02-03ER63601 from BER/DOE. The content is solely the responsibility*
 * of the authors and does not necessarily represent the official views of *
 * the funding organizations.                                              *
 *                                                                         *
 * The code for use of RasMol under GTK in RasMol 2.7.4.2 and 2.7.5 was    *
 * written by Teemu Ikonen.                                                *
 *                                                                         *
 *                    and Incorporating Translations by                    *
 *  Author                               Item                     Language *
 *  Isabel Servan Martinez,                                                *
 *  Jose Miguel Fernandez Fernandez      2.6   Manual             Spanish  *
 *  Jose Miguel Fernandez Fernandez      2.7.1 Manual             Spanish  *
 *  Fernando Gabriel Ranea               2.7.1 menus and messages Spanish  *
 *  Jean-Pierre Demailly                 2.7.1 menus and messages French   *
 *  Giuseppe Martini, Giovanni Paolella, 2.7.1 menus and messages          *
 *  A. Davassi, M. Masullo, C. Liotto    2.7.1 help file          Italian  *
 *  G. Pozhvanov                         2.7.3 menus and messages Russian  *
 *  G. Todorov                           2.7.3 menus and messages Bulgarian*
 *  Nan Jia, G. Todorov                  2.7.3 menus and messages Chinese  *
 *  Mamoru Yamanishi, Katajima Hajime    2.7.3 menus and messages Japanese *
 *                                                                         *
 *                             This Release by                             *
 * Herbert J. Bernstein, Bernstein + Sons, 5 Brewster Ln, Bellport, NY, USA*
 *                       yaya@bernstein-plus-sons.com                      *
 *               Copyright(C) Herbert J. Bernstein 1998-2008               *
 *                                                                         *
 *                READ THE FILE NOTICE FOR RASMOL LICENSES                 *
 *Please read the file NOTICE for important notices which apply to this    *
 *package and for license terms (GPL or RASLIC).                           *
 ***************************************************************************/
/* command.c
 */

#include "rasmol.h"

#ifdef MSWIN
#include <windows.h>
#endif
#ifndef sun386
#include <stdlib.h>
#endif

#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <math.h>

#if !defined(IBMPC) && !defined(VMS) && !defined(APPLEMAC)
#ifndef _WIN32
#ifndef _WIN32
#include <pwd.h>
#endif
#endif
#endif

#define COMMAND
#include "command.h"
#include "tokens.h"
#include "abstree.h"
#include "molecule.h"
#include "graphics.h"
#include "render.h"
#include "repres.h"
#include "infile.h"
#include "outfile.h"
#include "multiple.h"
#include "script.h"
#include "langsel.h"
#include "maps.h"

#define MAX_TOKEN   256

#define IsDataBlock(x)  ( (x==TOK_PDB)  || (x==TOK_NMRPDB) || \
                          (x==TOK_CIF)  || (x==TOK_XYZ)    || \
                          (x==TOK_MDL)  || (x==TOK_MOL2)   || \
                          (x==TOK_ALCHEMY) || (x==TOK_CHARMM) ||\
                          (x==TOK_MOPAC) || (x==TOK_CEX) )

/*=======================*/
/*  Function Prototypes  */
/*=======================*/

static void ZapDatabase( void );
static char *ProcessFileName( char* );


/*=======================*/
/*  Forward Declaration  */
/* Forward Declaration  */
/*=======================*/

void CommandError( char * );


/*============================================================================*/

static void CommandError( char *msg )
{
    char buffer[80];

    InvalidFlag = True;
    if( !CommandActive )
    {   if( FileLine > 0 )
        {   sprintf(buffer,"[%ld:%ld] ",(long)FileLine,(long)FileCol);
            WriteString(buffer);
        } else WriteString("Script: ");
    }
    WriteString(msg);
    WriteChar('\n');
}


static void ZapDatabase( void )
{
    if( Database )
    {   ReDrawFlag |= RFRefresh;
        ZapMolecule();
    }
}


static char *ProcessFileName( char *name )
{
    static char DataFileName[MAX_TOKEN];
    char username[MAX_TOKEN];
#ifndef _WIN32
#ifndef _WIN32
    struct passwd *entry;
#endif
#endif
    char *temp, *ptr;

    while( *name==' ' )
        name++;
    
    /* Perform filename globbing */
    if( *name=='~' )
    {   ptr = username;  name++;
        while( *name && (*name!=' ') && (*name!='/') )
            *ptr++ = *name++;
        *ptr = '\0';
        
        ptr = DataFileName;
        if( *username )
        {
#ifndef _WIN32
#ifndef _WIN32
            if( (entry=getpwnam(username)) )
#else
            if( 0 )
#endif
            {   temp = entry->pw_dir;
#ifndef _WIN32
                endpwent();
#endif
            } else
#endif
            /* Unknown user! */
            {   temp = username;
                *ptr++ = '~';
            }

        } else if( !(temp=(char*)getenv("HOME")) )
            temp = ".";

        while( *temp )
            *ptr++ = *temp++;
        while( *name && (*name!=' ') )
            *ptr++ = *name++;
    } else ptr = DataFileName;

    while( *name && (*name!=' ') )
    {   if( *name=='\\' )
        {   name++;
            if( *name )
                *ptr++ = *name++;
        } else *ptr++ = *name++;
    }
    *ptr = '\0';
    return DataFileName;
}

void ExecuteCommand( void )
{
    int stat;

    InvalidFlag = False;
    CommandActive = True;
    while( *TokenPtr && !InvalidFlag )
    {   stat = Command();
        if( stat )
            break;

        if( *TokenPtr == ';' )
        {   TokenPtr++;
        } else if( *TokenPtr )
            CommandError(MsgStrs[StrExpSemi]);
    }
    CommandActive = False;
}


int Command( void )
{
    static char MapLabel[256];
    char temp[MAX_TOKEN];
    char *ptr, *dst;
    Atom __far *aptr;
    Real speed;
    int ident;
    int mode;
    int val;

    if( !*TokenPtr || (*TokenPtr==';') )
        return 0;

    switch( FetchToken() )
    {
        case( TOK_BACKBONE ):
             if( IsEmptyToken() )
             {   mode = 2;
             } else if( !FetchSetMode(&mode) )
             {   CommandError(MsgStrs[StrBadArg]);
                 return 0;
             }
             if( !InvalidFlag )
                 BackboneStick(mode);
             break;

        case( TOK_BACKGROUND ):
             if( !FetchColour(&ident) )
             {   CommandError(MsgStrs[StrBadArg]);
             } else SetBackgroundColour(ident);
             break;

        case( TOK_BALLSTICK ):
             if( IsEmptyToken() )
             {   /* Default Values */
                 ident = 0; mode = 0;
             } else
             {   if( IsNumberToken() )
                 {   FetchInteger(&ident);
                 } else ident = 0;

                 if( IsEmptyToken() || (*TokenPtr==';') )
                 {   mode = 0;
                 } else if( !FetchSetMode(&mode) )
                 {   CommandError(MsgStrs[StrBadArg]);
                     return 0;
                 }
             }
             if( !InvalidFlag )
                 BallAndStick(mode,ident);
             break;

        case( TOK_BOND ):
             if( IsEmptyToken() )
             {   CommandError(MsgStrs[StrBadArg]);
             } else if( !FetchSetMode(&mode) )
             {   CommandError(MsgStrs[StrBadArg]);
             } else BondOrder(mode);
             break;

        case( TOK_CARTOONS ):
             if( IsEmptyToken() )
             {   mode = 0;
             } else if( !FetchSetMode(&mode) )
             {   CommandError(MsgStrs[StrBadArg]);
                 return 0;
             }
             if( !InvalidFlag )
                 MonomerCartoon(mode);
             break;

        case( TOK_CENTRE ):
        case( TOK_CENTER ):
             if( IsEmptyToken() )
             {   ResetCentre();
             } else
             {   ident = FetchExpression();
                 if( !InvalidFlag )
                     SetCentreExpression(ident);
             }
             break;

        case( TOK_CLIP ):
             if( IsEmptyToken() || (FetchToken()==TOK_OFF) )
             {   val = False;
             } else if( (TokenValue==TOK_ON) )
             {   val = True;
             } else
             {   CommandError(MsgStrs[StrBadArg]);
                 break;
             }
             if( !InvalidFlag )
                 SetClipStatus(val);
             break;

        case( TOK_COLOUR ):
        case( TOK_COLOR ):
             if( IsEmptyToken() )
             {   CommandError(MsgStrs[StrBadArg]);
                 break;
             }

             dst = temp;
             ident = FetchToken();
             if( ident == TOK_BONDS )
             {   if( IsEmptyToken() )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else if( !FetchColour(&ident) )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else ColourBonds(ident);
             } else if( ident == TOK_BACKBONE )
             {   if( IsEmptyToken() )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else if( !FetchColour(&ident) )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else ColourBackbone(ident);
             } else if( ident == TOK_RIBBONS )
             {   if( IsEmptyToken() )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else if( !FetchColour(&ident) )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else ColourRibbons(ident);
             } else if( ident == TOK_LABELS )
             {   if( IsEmptyToken() )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else if( FetchToken()==TOK_NONE )
                 {   ColourLabels(0);
                 } else if( !FetchColour(&ident) )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else ColourLabels(ident);
             } else if( ident == TOK_DOTS )
             {   if( IsEmptyToken() )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else if( !FetchColour(&ident) )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else ColourDots(ident);
             } else if( ident == TOK_HBONDS )
             {   if( IsEmptyToken() )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else if( !FetchColour(&ident) )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else ColourHBonds(ident);
             } else if( ident == TOK_SSBONDS )
             {   if( IsEmptyToken() )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else if( !FetchColour(&ident) )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else ColourSSBonds(ident);
             } else if( ident == TOK_MAP )
             {   if (FetchToken() == TOK_IDENT) {
                     strncpy(MapLabel, TokenIdent, 255);
                     if (FetchToken() == TOK_COLOUR || TokenValue == TOK_COLOR) {
                         if (FetchColour(&ident)) {
                             MapInfo __far * mapinfo;
                             mapinfo = MapList;
                             while (mapinfo) {
                                 if (mapinfo->MapLabel
                                     && !strcasecmp(mapinfo->MapLabel,MapLabel)) {
                                     mapinfo->MapColour = ident;
                                     break;
                                 }
                                 mapinfo = mapinfo->next;
                             }
                         } else {
                             CommandError(MsgStrs[StrBadArg]);
                         }
                     } else {
                         CommandError(MsgStrs[StrBadArg]);
                     }
                 } else {
                      CommandError(MsgStrs[StrBadArg]);
                 }
             } else
             {   while( *TokenIdent )
                     *dst++ = *TokenIdent++;
                 *dst = '\0';
                 if( !FetchColour(&ident) )
                 {   CommandError(MsgStrs[StrBadArg]);
                 } else ColourObject(ident,temp);
             }
             break;

        case( TOK_CONNECT ):
             if( IsEmptyToken() )
             {   val = True;
             } else if( FetchToken()==TOK_OFF )
             {   val = False;
             } else if( TokenValue==TOK_ON )
             {   val = True;
             } else
             {   CommandError(MsgStrs[StrBadArg]);
                 break;
             }
             InitialiseBonds(val);
             break;

        case( TOK_CPK ):
             if( IsEmptyToken() )
             {   ident = 0; mode = 2;
             } else
             {   if( IsNumberToken() )
                 {   FetchInteger(&ident);
                 } else ident = 0;

                 if( IsEmptyToken() || (*TokenPtr==';') )
                 {   mode = 2;
                 } else if( !FetchSetMode(&mode) )
                 {   CommandError(MsgStrs[StrBadArg]);
                     return 0;
                 }
             }
             if( !InvalidFlag )
                 CPKAndDots(mode,ident);
             break;

        case( TOK_DEFINE ):
             if( FetchToken() != TOK_IDENT )
             {   CommandError(MsgStrs[StrIdenExp]);
             } else
             {   strncpy(temp,TokenIdent,MAX_TOKEN);
                 ident = FetchExpression();
                 if( !InvalidFlag )
                     DefineSet(temp,ident);
             }
             break;

        case( TOK_DOTS ):
             if( IsEmptyToken() )
             {   val = True; mode = 2;
             } else
             {   if( FetchToken()==TOK_OFF )
                 {   val = False; mode = 2;
                 } else if( TokenValue==TOK_ON )
                 {   val = True; mode = 2;
                 } else if( IsNumberToken() )
                 {   FetchInteger(&val);
                     if( !IsEmptyToken() && FetchSetMode(&mode) )
                     {   /* mode fetched! */
                     } else mode = 2;
                 } else
                 {   CommandError(MsgStrs[StrBadArg]);
                     break;
                 }
             }
             if( !InvalidFlag )
                 CPKAndDots(mode,val);
             break;

        case( TOK_ECHO ):
             ptr = TokenPtr;
             while( *ptr && (*ptr!=';') )
                 ptr++;

             ident = (int)(ptr-TokenPtr);
             strncpy(temp,TokenPtr,ident);
             temp[ident] = '\0';
             WriteString(temp);
             WriteChar('\n');
             TokenPtr = ptr;
             break;

        case( TOK_ENGLISH ):  SetLanguage(English);   break;
        case( TOK_FRENCH ):   SetLanguage(French);    break;
        case( TOK_GERMAN ):   SetLanguage(German);    break;
        case( TOK_ITALIAN ):  SetLanguage(Italian);   break;
        case( TOK_SPANISH ):  SetLanguage(Spanish);   break;
        case( TOK_RUSSIAN ):  SetLanguage(Russian);   break;
        case( TOK_BULGARIAN): SetLanguage(Bulgarian); break;
        case( TOK_CHINESE ):  SetLanguage(Chinese);   break;
        case( TOK_JAPANESE ): SetLanguage(Japanese);  break;

        case( TOK_HBONDS ):
             if( IsEmptyToken() )
             {   ident = 0; mode = 2;
             } else
             {   if( IsNumberToken() )
                 {   FetchInteger(&ident);
                 } else ident = 0;

                 if( IsEmptyToken() || (*TokenPtr==';') )
                 {   mode = 2;
                 } else if( !FetchSetMode(&mode) )
                 {   CommandError(MsgStrs[StrBadArg]);
                     return 0;
                 }
             }
             if( !InvalidFlag )
                 HydrogenBonds(mode,ident);
             break;

        case( TOK_HELP ):
             if( IsEmptyToken() )
             {   ptr = (char*)0;
             } else if( FetchToken()==TOK_IDENT )
             {   ptr = TokenIdent;
             } else
             {   CommandError(MsgStrs[StrBadArg]);
                 break;
             }
             if( !InvalidFlag )
                 GiveHelp(ptr);
             break;

        case( TOK_LABEL ):
             if( IsEmptyToken() )
             {   val = True;
                 ptr = (char*)0;
             } else if( FetchToken()==TOK_OFF )
             {   val = False;
                 ptr = (char*)0;
             } else if( TokenValue==TOK_ON )
             {   val = True;
                 ptr = (char*)0;
             } else if( TokenValue==TOK_STRING )
             {   val = True;
                 ptr = TokenIdent;
             } else
             {   CommandError(MsgStrs[StrBadArg]);
                 break;
             }
             if( !InvalidFlag )
                 LabelObject(ptr,val);
             break;

        case( TOK_LOAD ):
             ident = FetchToken();
             if( IsDataBlock(ident) )
             {   ptr = ProcessFileName(TokenPtr);
                 dst = temp;
                 while( *ptr ) *dst++ = *ptr++;
                 *dst = '\0';

                 ZapDatabase();
                 if( !LoadDataFile(ident,temp) )
                 {   #ifdef PROFILE
                     if( FileLine > 0 )
                     {   sprintf(buffer,"[%ld:%ld] ",
                                 (long)FileLine,(long)FileCol);
                         WriteString(buffer);
                     } else WriteString("Script: ");
                     #endif
                     WriteString(MsgStrs[StrFileNotFound]);
                     WriteString(": "); WriteString(temp);
                     WriteChar('\n');
                 }
                 TokenPtr = (char*)0;
             } else
             {   ptr = ProcessFileName(TokenPtr);
                 dst = temp;
                 while( *ptr ) *dst++ = *ptr++;
                 *dst = '\0';

                 ZapDatabase();
                 if( !LoadDataFile(TOK_PDB,temp) )
                 {   #ifdef PROFILE
                     if( FileLine > 0 )
                     {   sprintf(buffer,"[%ld:%ld] ",
                                 (long)FileLine,(long)FileCol);
                         WriteString(buffer);
                     } else WriteString("Script: ");
                     #endif
                     WriteString(MsgStrs[StrFileNotFound]);
                     WriteString(": "); WriteString(temp);
                     WriteChar('\n');
                 }
                 TokenPtr = (char*)0;
             }
             return 1;

        case( TOK_MAP ):
             ident = FetchToken();
             if (ident == TOK_SELECT) {
                 if (FetchToken() == TOK_IDENT) {
                     strncpy(MapLabel, TokenIdent, 255);
                     SetMapSelect(MapLabel);
                 } else {
                     CommandError(MsgStrs[StrBadArg]);
                 }
                 break;
             }
             if (ident == TOK_GENERATE) {
                 FetchInteger(&ident);
                 if (!InvalidFlag) MapGenerate(ident);
                 break;
             }
             if (ident == TOK_LEVEL) {
                 if (FetchToken() == TOK_MEAN) {
                     if (FetchToken() == TOK_ADD || TokenValue == TOK_PLUS) {
                         FetchReal(&speed);
                     } else if (FetchToken() == TOK_SUB || TokenValue == TOK_MINUS) {
                         FetchReal(&speed);
                         speed = -speed;
                     } else {
                         CommandError(MsgStrs[StrBadArg]);
                         break;
                     }
                     if (!InvalidFlag) SetMapLevel(speed, True);
                 } else {
                     FetchReal(&speed);
                     if (!InvalidFlag) SetMapLevel(speed, False);
                 }
                 break;
             }
             if (ident == TOK_SPACING) {
                 FetchReal(&speed);
                 if (!InvalidFlag) SetMapSpacing(speed);
                 break;
             }
             if (ident == TOK_SPREAD) {
                 FetchReal(&speed);
                 if (!InvalidFlag) SetMapSpread(speed);
                 break;
             }
             if (ident == TOK_ZAP) {
                 if (FetchToken() == TOK_IDENT) {
                     strncpy(MapLabel, TokenIdent, 255);
                     ZapMap(MapLabel);
                 } else {
                     ZapMap((char *)0);
                 }
                 break;
             }
             if (ident == TOK_OFF) {
                 SetMapShow(0);
                 break;
             }
             if (ident == TOK_ON) {
                 SetMapShow(1);
                 break;
             }
             if (ident == TOK_COLOUR || ident == TOK_COLOR) {
                 SetMapShow(2);
                 break;
             }
             if (ident == TOK_DOTS) {
                 SetMapShow(3);
                 break;
             }
             if (ident == TOK_MESH) {
                 SetMapShow(4);
                 break;
             }
             if (ident == TOK_SURFACE) {
                 SetMapShow(5);
                 break;
             }
             if (ident == TOK_IDENT) {
                 strncpy(MapLabel, TokenIdent, 255);
                 FetchToken();
                 ptr = ProcessFileName(TokenPtr);
                 dst = temp;
                 while( *ptr ) *dst++ = *ptr++;
                 *dst = '\0';
                 if( !LoadMapFile(MapLabel,temp) )
                 {
                     WriteString(MsgStrs[StrFileNotFound]);
                     WriteString(": "); WriteString(temp);
                     WriteChar('\n');
                 }
                 TokenPtr = (char*)0;
                 return 1;
             }
             break;

        case( TOK_MOLECULE ):
             if( IsNumberToken() )
             {   FetchInteger(&ident);
             } else ident = 0;
             if( !InvalidFlag )
                 SelectMolecule(ident);
             break;

        case( TOK_MONITOR ):
             if( IsEmptyToken() )
             {   val = True;
             } else if( FetchToken()==TOK_OFF )
             {   val = False;
             } else if( TokenValue==TOK_ON )
             {   val = True;
             } else
             {   CommandError(MsgStrs[StrBadArg]);
                 break;
             }
             if( !InvalidFlag )
                 MonitorAtoms(val);
             break;

        case( TOK_MOVE ):
             /* move x,y,z, zoom, transx,transy,transz, slab, time */
             {  int rotx, roty, rotz;
                int zoom, tx, ty, tz, slab;
                long timeout;

                if( !FetchInteger(&rotx) ) break;
                if( !FetchInteger(&roty) ) break;
                if( !FetchInteger(&rotz) ) break;
                if( !FetchInteger(&zoom) ) break;
                if( !FetchInteger(&tx)   ) break;
                if( !FetchInteger(&ty)   ) break;
                if( !FetchInteger(&tz)   ) break;
                if( !FetchInteger(&slab) ) break;
                if( !FetchInteger(&val)  ) break;
                timeout = (long)val;

                if( !InvalidFlag )
                    MoveWait( rotx,roty,rotz, zoom, tx,ty,tz, slab, timeout );
             }
             break;

        case( TOK_PAUSE ):
        case( TOK_WAIT ):
             if( IsEmptyToken() )
             {   timeout = -1;
             } else if( !FetchInteger(&val) )
             {   CommandError(MsgStrs[StrBadArg]);
                 break;
             } else timeout = (long)val;
             if( !InvalidFlag )
                 ExecutePause(timeout);
             break;

        case( TOK_PRINT ):
             if( !InvalidFlag )
                 PrintImage();
             break;

        case( TOK_QUIT ):
        case( TOK_EXIT ):
             if( !InvalidFlag )
                 RasMolExit();
             break;

        case( TOK_REFRESH ):
             if( !InvalidFlag )
                 RefreshScreen();
             break;

        case( TOK_RENUMBER ):
             if( IsEmptyToken() )
             {   val = 0;
             } else if( !FetchInteger(&val) )
             {   CommandError(MsgStrs[StrBadArg]);
                 break;
             }
             if( !InvalidFlag )
                 RenumberAtoms(val);
             break;

        case( TOK_RESET ):
             if( !InvalidFlag )
                 ResetTransform();
             break;

        case( TOK_RESTRICT ):
             ident = FetchExpression();
             if( !InvalidFlag )
                 RestrictExpression(ident);
             break;

        case( TOK_RIBBONS ):
             if( IsEmptyToken() )
             {   ident = 0; mode = 2;
             } else
             {   if( IsNumberToken() )
                 {   FetchInteger(&ident);
                 } else ident = 0;

                 if( IsEmptyToken() || (*TokenPtr==';') )
                 {   mode = 2;
                 } else if( !FetchSetMode(&mode) )
                 {   CommandError(MsgStrs[StrBadArg]);
                     return 0;
                 }
             }
             if( !InvalidFlag )
                 RibbonStick(mode,ident);
             break;

        case( TOK_ROTATE ):
             dst = temp;
             ident = FetchToken();
             if( (ident==TOK_BOND) || (ident==TOK_IDENT && !strcasecmp(TokenIdent,"bond")) ) {
                 FetchReal(&speed);
                 if( !InvalidFlag )
                     RotateBond(speed);
             } else if( ident==TOK_X )
             {   FetchReal(&speed);
                 if( !InvalidFlag )
                     RotateObject(0,speed);
             } else if( ident==TOK_Y )
             {   FetchReal(&speed);
                 if( !InvalidFlag )
                     RotateObject(1,speed);
             } else if( ident==TOK_Z )
             {   FetchReal(&speed);
                 if( !InvalidFlag )
                     RotateObject(2,speed);
             } else
             {   CommandError(MsgStrs[StrBadArg]);
             }
             break;

        case( TOK_SAVE ):
             ident = FetchToken();
             if( ident==TOK_PDB )
             {   ident = TOK_PDB;
             } else if( ident==TOK_ALCHEMY )
             {   ident = TOK_ALCHEMY;
             } else if( ident==TOK_XYZ )
             {   ident = TOK_XYZ;
             } else ident = TOK_PDB;

             ptr = ProcessFileName(TokenPtr);
             dst = temp;
             while( *ptr ) *dst++ = *ptr++;
             *dst = '\0';

             if( !InvalidFlag )
                 SaveAtoms(ident,temp);
             TokenPtr = (char*)0;
             return 1;

        case( TOK_SCRIPT ):
             ptr = ProcessFileName(TokenPtr);
             dst = temp;
             while( *ptr ) *dst++ = *ptr++;
             *dst = '\0';

             if( !InvalidFlag )
                 ExecuteScript(temp,False);
             TokenPtr = (char*)0;
             return 1;

        case( TOK_SELECT ):
             ident = FetchExpression();
             if( !InvalidFlag )
                 SelectExpression(ident);
             break;

        case( TOK_SET ):
             ident = FetchToken();
             switch( ident )
             {   case( TOK_AMBIENT ):
                      FetchInteger(&val);
                      if( !InvalidFlag )
                          SetAmbient(val);
                      break;

                 case( TOK_AXES ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetAxesStatus(val);
                      break;

                 case( TOK_BACKGROUND ):
                      if( !FetchColour(&val) )
                      {   CommandError(MsgStrs[StrBadArg]);
                      } else SetBackgroundColour(val);
                      break;

                 case( TOK_BACKFADE ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetBackFadeStatus(val);
                      break;

                 case( TOK_BONDMODE ):
                      ident = FetchToken();
                      if( (ident==TOK_AND) || (ident==TOK_ALL) )
                      {   val = True;
                      } else if( (ident==TOK_OR) || (ident==TOK_NONE) )
                      {   val = False;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetBondMode(val);
                      break;

                 case( TOK_BOUNDBOX ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetBoxStatus(val);
                      break;

                 case( TOK_CARTOON ):
                      if( FetchToken()==TOK_ALL )
                      {   val = True;
                      } else if( TokenValue==TOK_NONE )
                      {   val = False;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetCartoonStatus(val);
                      break;

                 case( TOK_DISPLAY ):
                      ident = FetchToken();
                      if( ident==TOK_SELECTED )
                      {   val = True;
                      } else if( ident==TOK_NORMAL )
                      {   val = False;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetDisplayMode(val);
                      break;

                 case( TOK_HBONDS ):
                      ident = FetchToken();
                      if( ident==TOK_BACKBONE )
                      {   val = True;
                      } else if( ident==TOK_SIDECHAIN )
                      {   val = False;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetHBondMode(val);
                      break;

                 case( TOK_HETERO ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetHeteroStatus(val);
                      break;

                 case( TOK_HOURGLASS ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetHourGlassStatus(val);
                      break;

                 case( TOK_HYDROGEN ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetHydrogenStatus(val);
                      break;

                 case( TOK_KINEMAGE ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetKinemageStatus(val);
                      break;

                 case( TOK_MENUS ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          EnableMenus(val);
                      break;

                 case( TOK_MIRROR ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetMirrorStatus(val);
                      break;

                 case( TOK_MONITOR ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetMonitorStatus(val);
                      break;

                 case( TOK_MOUSE ):
                      ident = FetchToken();
                      if( ident==TOK_RASMOL )
                      {   val = True;
                      } else if( ident==TOK_INSIGHT )
                      {   val = False;
                      } else if( ident==TOK_QUANTA )
                      {   val = 2;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetMouseMode(val);
                      break;

                 case( TOK_PICKING ):
                      ident = FetchToken();
                      if( ident==TOK_OFF || ident==TOK_NONE )
                      {   mode = PickNone;
                      } else if( ident==TOK_IDENT )
                      {   mode = PickIdent;
                      } else if( ident==TOK_DISTANCE )
                      {   mode = PickDist;
                      } else if( ident==TOK_MONITOR )
                      {   mode = PickMonit;
                      } else if( ident==TOK_ANGLE )
                      {   mode = PickAngle;
                      } else if( ident==TOK_TORSION )
                      {   mode = PickTorsn;
                      } else if( ident==TOK_LABEL )
                      {   mode = PickLabel;
                      } else if( ident==TOK_CENTRE || ident==TOK_CENTER )
                      {   mode = PickCentre;
                      } else if( ident==TOK_BOND )
                      {   mode = PickBond;
                      } else if( ident==TOK_ATOM )
                      {   mode = PickAtom;
                      } else if( ident==TOK_GROUP )
                      {   mode = PickGroup;
                      } else if( ident==TOK_CHAIN )
                      {   mode = PickChain;
                      } else if( ident==TOK_MOLECULE )
                      {   mode = PickMolecule;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetPickingMode(mode);
                      break;

                 case( TOK_RADIUS ):
                      if( IsEmptyToken() )
                      {   val = 0;
                      } else if( !FetchInteger(&val) )
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetBondRadius(val);
                      break;

                 case( TOK_SHADOW ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetShadowStatus(val);
                      break;

                 case( TOK_SLAB ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else if( IsNumberToken() )
                      {   FetchInteger(&val);
                          SetSlabValue(val);
                          val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetSlabStatus(val);
                      break;

                 case( TOK_SPECULAR ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetSpecStatus(val);
                      break;

                 case( TOK_SPECPOWER ):
                      FetchInteger(&val);
                      if( !InvalidFlag )
                          SetSpecPower(val);
                      break;

                 case( TOK_SSBONDS ):
                      ident = FetchToken();
                      if( ident==TOK_BACKBONE )
                      {   val = True;
                      } else if( ident==TOK_SIDECHAIN )
                      {   val = False;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetSSBondMode(val);
                      break;

                 case( TOK_STEREO ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False; mode = 0;
                      } else if( TokenValue==TOK_ON )
                      {   val = True; mode = 0;
                      } else if( TokenValue==TOK_IDENT )
                      {   if( !strcasecmp(TokenIdent,"cross") )
                          {   val = True; mode = 1;
                          } else if( !strcasecmp(TokenIdent,"wall") )
                          {   val = True; mode = 0;
                          } else { CommandError(MsgStrs[StrBadArg]); break; }
                      } else if( IsNumberToken() )
                      {   FetchInteger(&val);
                          SetStereoAngle( (double)val );
                          val = True; mode = 0;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetStereoStatus(val,mode);
                      break;

                 case( TOK_STRANDS ):
                      FetchInteger(&val);
                      if( !InvalidFlag )
                          SetStrandCount(val);
                      break;

                 case( TOK_TRANSPARENT ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetTransStatus(val);
                      break;

                 case( TOK_UNITCELL ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetUnitCellStatus(val);
                      break;

                 case( TOK_VECTPS ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetVectPSStatus(val);
                      break;

                 case( TOK_WRITE ):
                      if( IsEmptyToken() )
                      {   val = True;
                      } else if( FetchToken()==TOK_OFF )
                      {   val = False;
                      } else if( TokenValue==TOK_ON )
                      {   val = True;
                      } else
                      {   CommandError(MsgStrs[StrBadArg]);
                          break;
                      }
                      if( !InvalidFlag )
                          SetWriteStatus(val);
                      break;

                 default:
                      CommandError(MsgStrs[StrBadArg]);
                      break;
             }
             break;

        case( TOK_SHOW ):
             ident = FetchToken();
             switch( ident )
             {   case( TOK_CENTRE ):
                 case( TOK_CENTER ):  ShowCentre();     break;
                 case( TOK_PHIPSI ):  ShowPhiPsi();     break;
                 case( TOK_RAMAC ):   ShowRamachandran(); break;
                 case( TOK_SELECTED ):ShowSelected();   break;
                 case( TOK_SEQUENCE ):ShowSequence();   break;
                 case( TOK_SYMMETRY ):ShowSymmetry();   break;
                 case( TOK_UNITCELL ):ShowUnitCell();   break;

                 case( TOK_HBONDS ):  ShowHBonds();     break;
                 case( TOK_SSBONDS ): ShowSSBonds();    break;
                 case( TOK_IDENT ):
                      if( !strcasecmp(TokenIdent,"axes") )
                      {   ShowAxes();
                      } else if( !strcasecmp(TokenIdent,"boundbox") )
                      {   ShowBoundBox();
                      } else if( !strcasecmp(TokenIdent,"information") )
                      {   ShowInformation();
                      } else if( !strcasecmp(TokenIdent,"translation") )
                      {   ShowTranslation();
                      } else if( !strcasecmp(TokenIdent,"rotation") )
                      {   ShowRotation();
                      } else if( !strcasecmp(TokenIdent,"zoom") )
                      {   ShowZoom();
                      } else CommandError(MsgStrs[StrBadArg]);
                      break;

                 default:
                      CommandError(MsgStrs[StrBadArg]);
                      break;
             }
             break;

        case( TOK_SLAB ):
             if( IsEmptyToken() )
             {   val = True;
             } else if( FetchToken()==TOK_OFF )
             {   val = False;
             } else if( TokenValue==TOK_ON )
             {   val = True;
             } else if( IsNumberToken() )
             {   FetchInteger(&val);
                 SetSlabValue(val);
                 val = True;
             } else
             {   CommandError(MsgStrs[StrBadArg]);
                 break;
             }
             if( !InvalidFlag )
                 SetSlabStatus(val);
             break;

        case( TOK_SPACEFILL ):
             if( IsEmptyToken() )
             {   ident = 0; mode = 2;
             } else
             {   if( IsNumberToken() )
                 {   FetchInteger(&ident);
                 } else if( (TokenValue==TOK_ON) || (TokenValue==TOK_TRUE) )
                 {   ident = 0;
                 } else if( (TokenValue==TOK_OFF) || (TokenValue==TOK_FALSE) )
                 {   ident = -1;
                 } else ident = 0;

                 if( IsEmptyToken() || (*TokenPtr==';') )
                 {   mode = 2;
                 } else if( !FetchSetMode(&mode) )
                 {   CommandError(MsgStrs[StrBadArg]);
                     return 0;
                 }
             }
             if( !InvalidFlag )
                 CPKAndDots(mode,ident);
             break;

        case( TOK_SSBONDS ):
             if( IsEmptyToken() )
             {   ident = 0; mode = 2;
             } else
             {   if( IsNumberToken() )
                 {   FetchInteger(&ident);
                 } else ident = 0;

                 if( IsEmptyToken() || (*TokenPtr==';') )
                 {   mode = 2;
                 } else if( !FetchSetMode(&mode) )
                 {   CommandError(MsgStrs[StrBadArg]);
                     return 0;
                 }
             }
             if( !InvalidFlag )
                 SSBonds(mode,ident);
             break;

        case( TOK_STEREO ):
             if( IsEmptyToken() )
             {   val = True; mode = 0;
             } else if( FetchToken()==TOK_OFF )
             {   val = False; mode = 0;
             } else if( TokenValue==TOK_ON )
             {   val = True; mode = 0;
             } else if( TokenValue==TOK_IDENT )
             {   if( !strcasecmp(TokenIdent,"cross") )
                 {   val = True; mode = 1;
                 } else if( !strcasecmp(TokenIdent,"wall") )
                 {   val = True; mode = 0;
                 } else { CommandError(MsgStrs[StrBadArg]); break; }
             } else if( IsNumberToken() )
             {   FetchInteger(&val);
                 SetStereoAngle( (double)val );
                 val = True; mode = 0;
             } else
             {   CommandError(MsgStrs[StrBadArg]);
                 break;
             }
             if( !InvalidFlag )
                 SetStereoStatus(val,mode);
             break;

        case( TOK_STRANDS ):
             if( IsEmptyToken() )
             {   ident = 0; mode = 2;
             } else
             {   if( IsNumberToken() )
                 {   FetchInteger(&ident);
                 } else ident = 0;

                 if( IsEmptyToken() || (*TokenPtr==';') )
                 {   mode = 2;
                 } else if( !FetchSetMode(&mode) )
                 {   CommandError(MsgStrs[StrBadArg]);
                     return 0;
                 }
             }
             if( !InvalidFlag )
                 MonomerStrands(mode,ident);
             break;

        case( TOK_STRUCTURE ):
             if( !InvalidFlag )
                 DetermineStructure(True);
             break;

        case( TOK_TRACE ):
             if( IsEmptyToken() )
             {   ident = 0; mode = 2;
             } else
             {   if( IsNumberToken() )
                 {   FetchInteger(&ident);
                 } else ident = 0;

                 if( IsEmptyToken() || (*TokenPtr==';') )
                 {   mode = 2;
                 } else if( !FetchSetMode(&mode) )
                 {   CommandError(MsgStrs[StrBadArg]);
                     return 0;
                 }
             }
             if( !InvalidFlag )
                 MonomerTrace(mode,ident);
             break;

        case( TOK_UNMONITOR ):
             if( IsEmptyToken() )
             {   /* Unmonitor All */
                 if( !InvalidFlag )
                     MonitorAtoms(False);
             } else
             {   FetchInteger(&ident);
                 if( IsEmptyToken() || (*TokenPtr==';') )
                 {   /* Unmonitor atom! */
                 } else if( FetchInteger(&mode) )
                 {   /* Unmonitor bond! */
                 }
             }
             break;

        case( TOK_WIREFRAME ):
             if( IsEmptyToken() )
             {   ident = 0; mode = 2;
             } else
             {   if( IsNumberToken() )
                 {   FetchInteger(&ident);
                 } else if( (TokenValue==TOK_ON) || (TokenValue==TOK_TRUE) )
                 {   ident = 0;
                 } else if( (TokenValue==TOK_OFF) || (TokenValue==TOK_FALSE) )
                 {   ident = -1;
                 } else ident = 0;

                 if( IsEmptyToken() || (*TokenPtr==';') )
                 {   mode = 2;
                 } else if( !FetchSetMode(&mode) )
                 {   CommandError(MsgStrs[StrBadArg]);
                     return 0;
                 }
             }
             if( !InvalidFlag )
                 WireframeStick(mode,ident);
             break;

        case( TOK_WRITE ):
             dst = temp;
             ident = FetchToken();
             if( ident == TOK_GIF )
             {   mode = OutputGIF;
             } else if( ident == TOK_PICT )
             {   mode = OutputPICT;
             } else if( ident == TOK_PS || ident == TOK_EPSF )
             {   mode = OutputPS;
             } else if( ident == TOK_PPM )
             {   mode = OutputPPM;
             } else if( ident == TOK_BMP )
             {   mode = OutputBMP;
             } else if( ident == TOK_SUN || ident == TOK_SUNRLE )
             {   mode = OutputSunRLE;
             } else if( ident == TOK_SUNRAS )
             {   mode = OutputSunRas;
             } else if( ident == TOK_IRIS )
             {   mode = OutputIris;
             } else if( ident == TOK_KINEMAGE )
             {   mode = OutputKinemage;
             } else if( ident == TOK_MOLSCRIPT )
             {   mode = OutputMolScript;
             } else if( ident == TOK_POVRay )
             {   mode = OutputPOVRay;
             } else if( ident == TOK_VRML )
             {   mode = OutputVRML;
             } else if( ident == TOK_STENCIL )
             {   mode = OutputStencil;
             } else if( ident == TOK_IDENT )
             {   if( !strcasecmp(TokenIdent,"vectps") )
                 {   mode = OutputVectPS;
                 } else { CommandError(MsgStrs[StrBadArg]); break; }
             } else { CommandError(MsgStrs[StrBadArg]); break; }

             ptr = ProcessFileName(TokenPtr);
             dst = temp;
             while( *ptr ) *dst++ = *ptr++;
             *dst = '\0';

             if( !InvalidFlag )
                 WriteImageFile(temp,mode);
             TokenPtr = (char*)0;
             return 1;

        case( TOK_ZAP ):
             ZapDatabase();
             break;

        case( TOK_ZOOM ):
             if( IsEmptyToken() )
             {   ResetTransform();
             } else if( FetchToken()==TOK_OFF )
             {   SetZoomStatus(False);
             } else if( TokenValue==TOK_ON )
             {   SetZoomStatus(True);
             } else if( IsNumberToken() )
             {   FetchInteger(&val);
                 if( !InvalidFlag )
                 {   ZoomObject(val);
                     SetZoomStatus(True);
                 }
             } else CommandError(MsgStrs[StrBadArg]);
             break;


        case( TOK_IDENT ):
             if( !strncasecmp("zap",TokenPtr,3) && (!(*(TokenPtr+3)) ||isspace(*(TokenPtr+3)))){
                 ZapDatabase();
             } else CommandError(MsgStrs[StrUnrecCom]);
             break;

        default:
             CommandError(MsgStrs[StrUnrecCom]);
             break;
    }
    return 0;
}
