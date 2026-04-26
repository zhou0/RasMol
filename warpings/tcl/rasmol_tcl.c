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

/* Tcl command to execute RasMol commands */
static int RasMol_CommandObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    if (objc != 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "command");
        return TCL_ERROR;
    }

    char *command = Tcl_GetString(objv[1]);
    ExecuteIPCCommand((char __huge *)command);
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

    /* Source the UI script */
    if (Tcl_Eval(interp, "if {[file exists gui/tcltk/rasmol_ui.tcl]} { source gui/tcltk/rasmol_ui.tcl }") == TCL_ERROR) {
        return TCL_ERROR;
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
void RefreshScreen( void ) {}
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
