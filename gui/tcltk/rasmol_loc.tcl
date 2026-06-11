# Localization for RasMol Tcl UI

set ::current_ui_lang "English"

array set ::ui_translations {
    "English" {
        "File" "File" "Open" "Open..." "SaveAs" "Save As..." "Close" "Close" "Exit" "Exit"
        "Display" "Display" "Wireframe" "Wireframe" "Backbone" "Backbone" "Sticks" "Sticks"
        "Spacefill" "Spacefill" "BallStick" "Ball & Stick" "Ribbons" "Ribbons"
        "Strands" "Strands" "Cartoons" "Cartoons" "MolSurf" "Molecular Surface"
        "Colours" "Colours" "Monochrome" "Monochrome" "CPK" "CPK" "Shapely" "Shapely"
        "Group" "Group" "Chain" "Chain" "Temp" "Temperature" "Struct" "Structure"
        "User" "User" "Model" "Model" "Alt" "Alt" "Options" "Options"
        "Slab" "Slab Mode" "Hydr" "Hydrogens" "Het" "Hetero Atoms" "Spec" "Specular"
        "Shad" "Shadows" "Stereo" "Stereo" "Label" "Labels" "Settings" "Settings"
        "POff" "Pick Off" "PIdent" "Pick Ident" "PDist" "Pick Distance" "PMon" "Pick Monitor"
        "PAng" "Pick Angle" "PTrsn" "Pick Torsion" "PLabl" "Pick Label" "PCent" "Pick Centre"
        "PCoord" "Pick Coord" "PBond" "Pick Bond" "RBond" "Rotate Bond" "RMol" "Rotate Molecule"
        "RAll" "Rotate All" "Export" "Export" "Help" "Help" "About" "About RasMol..."
        "UserM" "User Manual..." "Language" "Language" "MouseMode" "Mouse Mode"
        "RenderingMode" "Rendering Mode" "AboutTitle" "About RasMol"
        "AppGraphics" "RasMol Molecular Graphics" "Version" "Version"
        "Maintainer" "Current Maintainer:" "OriginalAuthor" "Original Author:"
        "Contributors" "Main Contributors:" "LicenseInfo" "GPL/RASMOL" "CloseBtn" "Close"
    }
    "Simplified Chinese" {
        "File" "文件" "Open" "打开..." "SaveAs" "另存为..." "Close" "关闭" "Exit" "退出"
        "Display" "展示" "Wireframe" "线框" "Backbone" "脊梁" "Sticks" "枝条"
        "Spacefill" "空间填充" "BallStick" "球形和枝状" "RenderingMode" "渲染模式"
        "Language" "语言" "Settings" "设置" "About" "关于 RasMol..." "CloseBtn" "关闭"
    }
}

proc tr {key} {
    if {[info exists ::ui_translations($::current_ui_lang)]} {
        foreach {k v} $::ui_translations($::current_ui_lang) { if {$k eq $key} { return $v } }
    }
    if {[info exists ::ui_translations(English)]} {
        foreach {k v} $::ui_translations(English) { if {$k eq $key} { return $v } }
    }
    return $key
}

proc localize_ui {} {
    set menu_map { .menubar.file "File" .menubar.display "Display" .menubar.colours "Colours"
                   .menubar.export "Export" .menubar.options "Options" .menubar.settings "Settings"
                   .menubar.help "Help" }
    foreach {path key} $menu_map {
        set idx [.menubar index $path]
        if {$idx ne "none"} { .menubar entryconfigure $idx -label [tr $key] }
    }
    foreach {old new} { "Open..." "Open" "Save As..." "SaveAs" "Close" "Close" "Exit" "Exit" } {
        catch { .menubar.file entryconfigure $old -label [tr $new] }
    }
    foreach {old new} { "Wireframe" "Wireframe" "Backbone" "Backbone" "Sticks" "Sticks"
                       "Spacefill" "Spacefill" "Ball & Stick" "BallStick" } {
        catch { .menubar.display entryconfigure $old -label [tr $new] }
    }
    foreach {old new} { "Language" "Language" "Mouse Mode" "MouseMode" "Rendering Mode" "RenderingMode" } {
        catch { .menubar.settings entryconfigure $old -label [tr $new] }
    }
}

proc set_language {lang} {
    set ::current_ui_lang $lang; localize_ui
}
