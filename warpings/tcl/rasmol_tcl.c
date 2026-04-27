#include <tcl.h>
#include <tk.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
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
static int opengl_mode = 0;

#ifdef USE_VTK
extern void VTK_Initialize();
extern int VTK_LoadPDB(const char* filename);
extern void VTK_RenderToBuffer(unsigned char* buffer, int width, int height);
#endif

/* Forward declaration for RefreshScreen */
void RefreshScreen( void );

/* Tcl command to execute RasMol commands */
static int RasMol_CommandObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    if (objc != 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "command");
        return TCL_ERROR;
    }

    void *old_db = Database;
    char *command = Tcl_GetString(objv[1]);

#ifdef USE_VTK
    if (opengl_mode && strncmp(command, "load ", 5) == 0) {
        char *filename = command + 5;
        if (strncmp(filename, "pdb ", 4) == 0) filename += 4;
        VTK_LoadPDB(filename);
    }
#endif

    ExecuteIPCCommand((char __huge *)command);

    if (Database && (Database != old_db)) {
        DefaultRepresentation();
        ReDrawFlag |= RFRefresh | RFApply;
    }

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

/* Tcl command to query RasMol info */
static int RasMol_InfoObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    if (objc != 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "topic");
        return TCL_ERROR;
    }

    char *topic = Tcl_GetString(objv[1]);
    if (strcmp(topic, "vtk") == 0) {
#ifdef USE_VTK
        Tcl_SetObjResult(interp, Tcl_NewBooleanObj(1));
#else
        Tcl_SetObjResult(interp, Tcl_NewBooleanObj(0));
#endif
    } else if (strcmp(topic, "molecules") == 0) {
        Tcl_SetObjResult(interp, Tcl_NewIntObj(NumMolecules));
    } else if (strcmp(topic, "atoms") == 0) {
        Tcl_SetObjResult(interp, Tcl_NewLongObj(MainAtomCount));
    } else {
        Tcl_SetObjResult(interp, Tcl_NewStringObj("unknown topic", -1));
        return TCL_ERROR;
    }
    return TCL_OK;
}

/* Tcl command to toggle OpenGL mode */
static int RasMol_OpenGLModeObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    if (objc > 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "?bool?");
        return TCL_ERROR;
    }

    if (objc == 2) {
        if (Tcl_GetBooleanFromObj(interp, objv[1], &opengl_mode) != TCL_OK) return TCL_ERROR;
#ifdef USE_VTK
        if (opengl_mode) {
            VTK_Initialize();
            if (DataFileName[0]) VTK_LoadPDB(DataFileName);
        }
#endif
        ReDrawFlag |= RFRefresh;
        RefreshScreen();
    }

    Tcl_SetObjResult(interp, Tcl_NewBooleanObj(opengl_mode));
    return TCL_OK;
}

/* Tcl command to handle Resizing */
static int RasMol_ResizeObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    int w, h;
    if (objc != 3) {
        Tcl_WrongNumArgs(interp, 1, objv, "width height");
        return TCL_ERROR;
    }
    if (Tcl_GetIntFromObj(interp, objv[1], &w) != TCL_OK) return TCL_ERROR;
    if (Tcl_GetIntFromObj(interp, objv[2], &h) != TCL_OK) return TCL_ERROR;

    if (w > 0 && h > 0) {
        XRange = w;
        YRange = h;
        WRange = XRange >> 1;
        HRange = YRange >> 1;
        Range = MinFun(XRange, YRange);

        ReDrawFlag |= RFReSize | RFRefresh | RFApply;
        RefreshScreen();
    }
    return TCL_OK;
}

/* Mouse and Keyboard bridge functions */

static int RasMol_MouseDownObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    int x, y, mask;
    if (objc != 4) {
        Tcl_WrongNumArgs(interp, 1, objv, "x y mask");
        return TCL_ERROR;
    }
    Tcl_GetIntFromObj(interp, objv[1], &x);
    Tcl_GetIntFromObj(interp, objv[2], &y);
    Tcl_GetIntFromObj(interp, objv[3], &mask);
    ProcessMouseDown(x, y, mask);
    RefreshScreen();
    return TCL_OK;
}

static int RasMol_MouseMoveObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    int x, y, mask;
    if (objc != 4) {
        Tcl_WrongNumArgs(interp, 1, objv, "x y mask");
        return TCL_ERROR;
    }
    Tcl_GetIntFromObj(interp, objv[1], &x);
    Tcl_GetIntFromObj(interp, objv[2], &y);
    Tcl_GetIntFromObj(interp, objv[3], &mask);
    ProcessMouseMove(x, y, mask);
    RefreshScreen();
    return TCL_OK;
}

static int RasMol_MouseUpObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    int x, y, mask;
    if (objc != 4) {
        Tcl_WrongNumArgs(interp, 1, objv, "x y mask");
        return TCL_ERROR;
    }
    Tcl_GetIntFromObj(interp, objv[1], &x);
    Tcl_GetIntFromObj(interp, objv[2], &y);
    Tcl_GetIntFromObj(interp, objv[3], &mask);
    ProcessMouseUp(x, y, mask);
    RefreshScreen();
    return TCL_OK;
}

static int RasMol_KeyPressObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    int key;
    if (objc != 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "key");
        return TCL_ERROR;
    }
    Tcl_GetIntFromObj(interp, objv[1], &key);
    ProcessCharacter(key);
    RefreshScreen();
    return TCL_OK;
}

/* Forward declaration for HandleMenu */
void HandleMenu( int hand );

/* Tcl command to handle RasMol menu actions */
static int RasMol_HandleMenuObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    int menu, item;
    if (objc != 3) {
        Tcl_WrongNumArgs(interp, 1, objv, "menu item");
        return TCL_ERROR;
    }

    if (Tcl_GetIntFromObj(interp, objv[1], &menu) != TCL_OK) return TCL_ERROR;
    if (Tcl_GetIntFromObj(interp, objv[2], &item) != TCL_OK) return TCL_ERROR;

    HandleMenu((menu << 8) | item);

    if (ReDrawFlag) {
        RefreshScreen();
        ReDrawFlag = NextReDrawFlag;
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

    ReDrawFlag |= RFReSize;

    Tcl_CreateObjCommand(interp, "rasmol_command", RasMol_CommandObjCmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "rasmol_register_photo", RasMol_RegisterPhotoObjCmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "rasmol_handle_menu", RasMol_HandleMenuObjCmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "rasmol_resize", RasMol_ResizeObjCmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "rasmol_opengl_mode", RasMol_OpenGLModeObjCmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "rasmol_info", RasMol_InfoObjCmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "rasmol_mouse_down", RasMol_MouseDownObjCmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "rasmol_mouse_move", RasMol_MouseMoveObjCmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "rasmol_mouse_up", RasMol_MouseUpObjCmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, "rasmol_key_press", RasMol_KeyPressObjCmd, NULL, NULL);

    /* Search for the UI script in multiple locations */
    const char *script_name = "rasmol_ui.tcl";
    const char *search_dirs[] = {
        "gui/tcltk",
        "../gui/tcltk",
        "../../gui/tcltk",
        "../../../gui/tcltk",
        "./",
        "/usr/local/share/rasmol",
        "/usr/share/rasmol",
        NULL
    };

    char full_path[1024];
    int found = 0;

    for (int i = 0; search_dirs[i] != NULL; i++) {
        snprintf(full_path, sizeof(full_path), "%s/%s", search_dirs[i], script_name);
        if (access(full_path, R_OK) == 0) {
            if (Tcl_EvalFile(interp, full_path) == TCL_OK) {
                found = 1;
                break;
            } else {
                fprintf(stderr, "Error executing RasMol UI script '%s':\n%s\n",
                        full_path, Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY));
            }
        }
    }

    if (!found) {
        fprintf(stderr, "Warning: Could not load RasMol UI script '%s' from any searched location.\n", script_name);
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
    if (opengl_mode) {
#ifdef USE_VTK
        VTK_RenderToBuffer((unsigned char*)FBuffer, XRange, YRange);
#endif
    } else {
        if( !UseSlabPlane ) {
            ReDrawFlag &= ~RFTransZ|RFSlab;
        } else {
            ReDrawFlag &= ~RFTransZ;
        }

        if( ReDrawFlag ) {
            if( ReDrawFlag & RFReSize )
                ReSizeScreen();

            if( ReDrawFlag & RFColour )
                DefineColourMap();

            NextReDrawFlag = 0;
            if( Database ) {
                if( ReDrawFlag & RFApply )
                    ApplyTransform();
                DrawFrame();
            }
        }
    }

    if (rasmol_photo_handle == NULL || FBuffer == NULL) return;

    /* Set Alpha channel to 255 for visibility */
    int i;
    unsigned char *p = (unsigned char *)FBuffer;
    for (i = 0; i < XRange * YRange; i++) {
        p[i*4 + 3] = 255;
    }

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

/* Placeholder for HandleMenu if not linked from rasmol.c */
void HandleMenu( int hand ) {
    int menu = hand >> 8;
    int item = hand & 0xff;

    switch(menu) {
        case 0: /* File */
            switch(item) {
                case 3: ExecuteIPCCommand("zap"); break;
                case 5: exit(0); break;
            }
            break;
        case 1: /* Display */
            switch(item) {
                case 1: ExecuteIPCCommand("wireframe"); break;
                case 2: ExecuteIPCCommand("backbone"); break;
                case 3: ExecuteIPCCommand("sticks"); break;
                case 4: ExecuteIPCCommand("spacefill"); break;
                case 5: ExecuteIPCCommand("ballstick"); break;
                case 6: ExecuteIPCCommand("ribbons"); break;
                case 7: ExecuteIPCCommand("strands"); break;
                case 8: ExecuteIPCCommand("cartoons"); break;
                case 9: ExecuteIPCCommand("surface"); break;
            }
            break;
        case 2: /* Colours */
            switch(item) {
                case 1: ExecuteIPCCommand("colour monochrome"); break;
                case 2: ExecuteIPCCommand("colour cpk"); break;
                case 3: ExecuteIPCCommand("colour shapely"); break;
                case 4: ExecuteIPCCommand("colour group"); break;
                case 5: ExecuteIPCCommand("colour chain"); break;
                case 6: ExecuteIPCCommand("colour temperature"); break;
                case 7: ExecuteIPCCommand("colour structure"); break;
                case 8: ExecuteIPCCommand("colour user"); break;
                case 9: ExecuteIPCCommand("colour model"); break;
                case 10: ExecuteIPCCommand("colour alt"); break;
            }
            break;
        case 3: /* Options */
            switch(item) {
                case 1: ExecuteIPCCommand("slab"); break;
                case 2: ExecuteIPCCommand("set hydrogens"); break;
                case 3: ExecuteIPCCommand("set hetero"); break;
                case 4: ExecuteIPCCommand("set specular"); break;
                case 5: ExecuteIPCCommand("set shadows"); break;
                case 6: ExecuteIPCCommand("stereo"); break;
                case 7: ExecuteIPCCommand("set labels"); break;
            }
            break;
        case 4: /* Settings */
            switch(item) {
                case 1: ExecuteIPCCommand("set picking off"); break;
                case 2: ExecuteIPCCommand("set picking ident"); break;
                case 3: ExecuteIPCCommand("set picking distance"); break;
                case 4: ExecuteIPCCommand("set picking monitor"); break;
                case 5: ExecuteIPCCommand("set picking angle"); break;
                case 6: ExecuteIPCCommand("set picking torsion"); break;
                case 7: ExecuteIPCCommand("set picking label"); break;
                case 8: ExecuteIPCCommand("set picking centre"); break;
                case 9: ExecuteIPCCommand("set picking coord"); break;
                case 10: ExecuteIPCCommand("set picking bond"); break;
                case 11: ExecuteIPCCommand("set rotation bond"); break;
                case 12: ExecuteIPCCommand("set rotation molecule"); break;
                case 13: ExecuteIPCCommand("set rotation all"); break;
            }
            break;
    }
}

int main(int argc, char *argv[]) {
    Tk_Main(argc, argv, Tcl_AppInit);
    return 0;
}
