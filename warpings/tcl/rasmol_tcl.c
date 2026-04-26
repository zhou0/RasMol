#include <tcl.h>
#include <tk.h>
#include <stdlib.h>
#include <string.h>
#include <cqrlib.h>
#include "rasmol.h"
#include "molecule.h"
#include "command.h"
#include "abstree.h"
#include "cmndline.h"
#include "outfile.h"
#include "pixutils.h"
#include "render.h"
#include "repres.h"
#include "transfor.h"
#include "graphics.h"

/* The Tk Photo handle for rendering */
static Tk_PhotoHandle rasmol_photo_handle = NULL;

/* Tcl command to execute RasMol commands */
static int RasMol_CommandObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    if (objc != 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "command");
        return TCL_ERROR;
    }

    char *command = Tcl_GetString(objv[1]);
    ExecuteIPCCommand((char __huge *)command);
    RefreshScreen();
    return TCL_OK;
}

/* Tcl command to register the Tk photo image */
static int RasMol_RegisterPhotoObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    if (objc != 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "photo_name");
        return TCL_ERROR;
    }

    char *photo_name = Tcl_GetString(objv[1]);
    rasmol_photo_handle = Tk_FindPhoto(interp, photo_name);

    if (rasmol_photo_handle == NULL) {
        Tcl_SetObjResult(interp, Tcl_NewStringObj("Could not find photo image", -1));
        return TCL_ERROR;
    }

    return TCL_OK;
}

int Tcl_AppInit(Tcl_Interp *interp) {
    if (Tcl_Init(interp) == TCL_ERROR) return TCL_ERROR;
    if (Tk_Init(interp) == TCL_ERROR) return TCL_ERROR;

    /* Initialize Display state FIRST so XRange/YRange are set */
    OpenDisplay();

    /* Initialize RasMol core */
    InitialiseCmndLine();
    InitialiseCommand();
    InitialiseTransform();
    InitialiseDatabase();
    InitialiseRenderer();
    InitialisePixUtils();
    InitialiseAbstree();
    InitialiseOutFile();
    InitialiseRepres();
    InitHelpFile();

    Tcl_CreateObjCommand(interp, "rasmol_command", RasMol_CommandObjCmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "rasmol_register_photo", RasMol_RegisterPhotoObjCmd, NULL, NULL);

    /* Source the UI script */
    if (Tcl_Eval(interp, "if {[file exists gui/tcltk/rasmol_ui.tcl]} { source gui/tcltk/rasmol_ui.tcl }") == TCL_ERROR) {
        // Warning only, as it might be sourced differently in production
    }

    return TCL_OK;
}

/* Global variables normally defined in GUI code but NOT in CORE_SOURCES */
int ReDrawFlag;
int NextReDrawFlag;
double DialValue[11];
double WorldDialValue[11];
double LastDialValue[11];
double LastWorldDialValue[11];
CQRQuaternion DialQRot;
CQRQuaternion WorldDialQRot;
int XRange, WRange, YRange, HRange, ZRange, Range;
int MouseUpdateStatus;
int MouseCaptureStatus;
int RepDefault;
int ColDefault;
int UseHourGlass;

Pixel __huge *FBuffer;
short __huge *DBuffer;
short __huge *SLineBuffer;
short __huge *DLineBuffer;

Pixel Lut[LutSize];
Byte RLut[LutSize];
Byte GLut[LutSize];
Byte BLut[LutSize];
Byte ULut[LutSize];

/* Dummy implementations of GUI-specific functions */
void WriteChar( int ch ) { putchar(ch); }
void WriteString( char *ptr ) { fputs(ptr, stdout); }
void WriteMsg( char *ptr ) { fputs(ptr, stdout); }
void RasMolFatalExit( char *ptr ) { fprintf(stderr, "Fatal Error: %s\n", ptr); exit(1); }
void AdviseUpdate( int item ) { (void)item; }

void RefreshScreen( void ) {
    if (rasmol_photo_handle == NULL || FBuffer == NULL) return;

    Tk_PhotoImageBlock block;
    block.width = XRange;
    block.height = YRange;
    block.pitch = XRange * 4;
    block.pixelSize = 4;
    block.pixelPtr = (unsigned char *)FBuffer;

    block.offset[0] = 0; /* Red */
    block.offset[1] = 1; /* Green */
    block.offset[2] = 2; /* Blue */
    block.offset[3] = 3; /* Alpha */

    Tk_PhotoPutBlock(NULL, rasmol_photo_handle, &block, 0, 0, XRange, YRange, TK_PHOTO_COMPOSITE_SET);
}

void RasMolExit( void ) { exit(0); }
void HandleMenu( int hand ) { (void)hand; }
void UpdateLanguage( void ) {}
void ReDrawWindow( void ) {}
void UpdateScrollBars( void ) {}
int LookUpColour( char *name, int *r, int *g, int *b ) { (void)name; (void)r; (void)g; (void)b; return False; }
void SetMouseUpdateStatus( int bool ) { MouseUpdateStatus = bool; }
void SetMouseCaptureStatus( int bool ) { MouseCaptureStatus = bool; }
void SetCanvasTitle( char *ptr ) { (void)ptr; }
void EnableMenus( int flag ) { (void)flag; }
void CloseDisplay( void ) {}
void BeginWait( void ) {}
void EndWait( void ) {}

int OpenDisplay( void ) {
    register int i;

    for( i=0; i<10; i++ )
        DialValue[i] = 0.0;

    XRange = 576;   WRange = XRange>>1;
    YRange = 576;   HRange = YRange>>1;
    Range = MinFun(XRange,YRange);
    ZRange = 20000;

    /* Initialise Palette! */
    for( i=0; i<LutSize; i++ )
        ULut[i] = False;
    return True;
}

int ClipboardImage( void ) { return False; }
void ClearImage( void ) {}
int PrintImage( void ) { return False; }
void AllocateColourMap( void ) {}

int CreateImage( void ) {
    size_t size;

    if( FBuffer ) _ffree( FBuffer );

    if (XRange <= 0 || YRange <= 0) return False;

    size = (size_t)XRange*YRange*sizeof(Pixel);
    FBuffer = (Pixel __huge*)_fmalloc( size );
    return( FBuffer != (Pixel __huge*)0 );
}

int ShowInterpNames ( void ) { return False; }
int CheckInterpName (char __huge *name , unsigned long __huge *id) { (void)name; (void)id; return False; }
int SendInterpCommand( char __huge *name, unsigned long id, char __huge *cmd) { (void)name; (void)id; (void)cmd; return False; }

int main(int argc, char *argv[]) {
    Tk_Main(argc, argv, Tcl_AppInit);
    return 0;
}
