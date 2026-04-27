#ifdef USE_VTK

#include <vtkPDBReader.h>
#include <vtkGlyph3DMapper.h>
#include <vtkSphereSource.h>
#include <vtkActor.h>
#include <vtkRenderer.h>
#include <vtkRenderWindow.h>
#include <vtkWindowToImageFilter.h>
#include <vtkImageExport.h>
#include <vtkSmartPointer.h>
#include <vtkProperty.h>
#include <vtkPolyData.h>
#include <vtkPointData.h>

#include <iostream>
#include <vector>

extern "C" {
    #include "rasmol.h"
    #include "graphics.h"
}

static vtkSmartPointer<vtkRenderer> vtk_renderer;
static vtkSmartPointer<vtkRenderWindow> vtk_render_window;
static vtkSmartPointer<vtkPDBReader> vtk_pdb_reader;
static vtkSmartPointer<vtkActor> vtk_molecule_actor;

extern "C" void VTK_Initialize() {
    if (!vtk_renderer) {
        vtk_renderer = vtkSmartPointer<vtkRenderer>::New();
        vtk_render_window = vtkSmartPointer<vtkRenderWindow>::New();
        vtk_render_window->AddRenderer(vtk_renderer);
        vtk_render_window->SetOffScreenRendering(1);

        vtk_pdb_reader = vtkSmartPointer<vtkPDBReader>::New();
        vtk_molecule_actor = vtkSmartPointer<vtkActor>::New();
    }
}

extern "C" int VTK_LoadPDB(const char* filename) {
    if (!vtk_pdb_reader) VTK_Initialize();

    vtk_pdb_reader->SetFileName(filename);
    vtk_pdb_reader->Update();

    vtkSmartPointer<vtkSphereSource> sphere = vtkSmartPointer<vtkSphereSource>::New();
    sphere->SetRadius(0.3);
    sphere->SetThetaResolution(8);
    sphere->SetPhiResolution(8);

    vtkSmartPointer<vtkGlyph3DMapper> mapper = vtkSmartPointer<vtkGlyph3DMapper>::New();
    mapper->SetInputConnection(vtk_pdb_reader->GetOutputPort());
    mapper->SetSourceConnection(sphere->GetOutputPort());
    mapper->SetScaleModeToDataScalingOff();

    vtk_molecule_actor->SetMapper(mapper);
    vtk_renderer->AddActor(vtk_molecule_actor);
    vtk_renderer->ResetCamera();

    return 1;
}

extern "C" void VTK_RenderToBuffer(unsigned char* buffer, int width, int height) {
    if (!vtk_render_window) return;

    vtk_render_window->SetSize(width, height);
    vtk_render_window->Render();

    vtkSmartPointer<vtkWindowToImageFilter> wif = vtkSmartPointer<vtkWindowToImageFilter>::New();
    wif->SetInput(vtk_render_window);
    wif->Update();

    vtkImageData* image = wif->GetOutput();
    int dims[3];
    image->GetDimensions(dims);

    unsigned char* pixels = static_cast<unsigned char*>(image->GetScalarPointer());

    // Copy pixels to RasMol FBuffer format (RGBA)
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int vtk_idx = ((height - 1 - y) * width + x) * 3;
            int buf_idx = (y * width + x) * 4;

            buffer[buf_idx]     = pixels[vtk_idx];     // R
            buffer[buf_idx + 1] = pixels[vtk_idx + 1]; // G
            buffer[buf_idx + 2] = pixels[vtk_idx + 2]; // B
            buffer[buf_idx + 3] = 255;                 // A
        }
    }
}

#endif
