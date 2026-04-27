#ifdef USE_VTK

#include <vtkPDBReader.h>
#include <vtkGlyph3DMapper.h>
#include <vtkSphereSource.h>
#include <vtkActor.h>
#include <vtkRenderer.h>
#include <vtkRenderWindow.h>
#include <vtkWindowToImageFilter.h>
#include <vtkSmartPointer.h>
#include <vtkProperty.h>
#include <vtkPolyData.h>
#include <vtkPointData.h>
#include <vtkImageData.h>
#include <vtkCamera.h>
#include <vtkLight.h>

#include <iostream>
#include <string>

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
        vtk_renderer->SetBackground(0.1, 0.1, 0.2);

        vtk_render_window = vtkSmartPointer<vtkRenderWindow>::New();
        vtk_render_window->AddRenderer(vtk_renderer);
        vtk_render_window->SetOffScreenRendering(1);

        vtk_pdb_reader = vtkSmartPointer<vtkPDBReader>::New();
        vtk_molecule_actor = vtkSmartPointer<vtkActor>::New();
        vtk_renderer->AddActor(vtk_molecule_actor);

        vtkSmartPointer<vtkLight> light = vtkSmartPointer<vtkLight>::New();
        light->SetLightTypeToHeadlight();
        vtk_renderer->AddLight(light);

        std::cout << "VTK Bridge: Backend initialized." << std::endl;
    }
}

extern "C" int VTK_LoadPDB(const char* filename) {
    if (!vtk_renderer) VTK_Initialize();

    std::string path = filename;
    // Clean up filename (remove quotes if any)
    if (path.size() >= 2 && path.front() == '"' && path.back() == '"') {
        path = path.substr(1, path.size() - 2);
    }

    if (path.empty()) return 0;

    std::cout << "VTK Bridge: Loading PDB: " << path << std::endl;
    vtk_pdb_reader->SetFileName(path.c_str());
    vtk_pdb_reader->Update();

    vtkPolyData* poly = vtk_pdb_reader->GetOutput();
    if (!poly || poly->GetNumberOfPoints() == 0) {
        std::cerr << "VTK Bridge Error: No atoms loaded from " << path << std::endl;
        return 0;
    }
    std::cout << "VTK Bridge: Loaded " << poly->GetNumberOfPoints() << " atoms." << std::endl;

    vtkSmartPointer<vtkSphereSource> sphere = vtkSmartPointer<vtkSphereSource>::New();
    sphere->SetRadius(0.5);
    sphere->SetThetaResolution(16);
    sphere->SetPhiResolution(16);

    vtkSmartPointer<vtkGlyph3DMapper> mapper = vtkSmartPointer<vtkGlyph3DMapper>::New();
    mapper->SetInputConnection(vtk_pdb_reader->GetOutputPort());
    mapper->SetSourceConnection(sphere->GetOutputPort());
    mapper->SetScaleModeToDataScalingOff();

    vtk_molecule_actor->SetMapper(mapper);
    vtk_molecule_actor->GetProperty()->SetColor(0.8, 0.8, 1.0);
    vtk_molecule_actor->VisibilityOn();

    vtk_renderer->ResetCamera();
    vtk_render_window->Render();
    return 1;
}

extern "C" void VTK_RenderToBuffer(unsigned char* buffer, int width, int height) {
    if (!vtk_render_window) return;

    if (vtk_render_window->GetSize()[0] != width || vtk_render_window->GetSize()[1] != height) {
        vtk_render_window->SetSize(width, height);
    }

    vtk_render_window->Render();

    vtkSmartPointer<vtkWindowToImageFilter> wif = vtkSmartPointer<vtkWindowToImageFilter>::New();
    wif->SetInput(vtk_render_window);
    wif->SetInputBufferTypeToRGB();
    wif->ReadFrontBufferOff();
    wif->Update();

    vtkImageData* image = wif->GetOutput();
    unsigned char* pixels = static_cast<unsigned char*>(image->GetScalarPointer());

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int vtk_idx = ((height - 1 - y) * width + x) * 3;
            int buf_idx = (y * width + x) * 4;

            // Map to RGBA for Tk (R, G, B, A)
            buffer[buf_idx]     = pixels[vtk_idx];     // R
            buffer[buf_idx + 1] = pixels[vtk_idx + 1]; // G
            buffer[buf_idx + 2] = pixels[vtk_idx + 2]; // B
            buffer[buf_idx + 3] = 255;                 // A
        }
    }
}

#endif
