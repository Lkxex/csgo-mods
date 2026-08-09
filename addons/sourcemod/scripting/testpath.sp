#include <sourcemod>
public void OnPluginStart() {
    char dir[PLATFORM_MAX_PATH] = "materials/decals/custom_gen";
    if (!DirExists(dir)) {
        CreateDirectory(dir, 511);
    }
    File f = OpenFile("materials/decals/custom_gen/test.txt", "w");
    if (f != null) {
        f.WriteLine("Hello");
        delete f;
    }
}
