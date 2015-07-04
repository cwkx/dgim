// Copyright 2015 Chris G. Willcocks
// License: GNU General Public License Version 3

import std.stdio, std.string;
import derelict.opengl3.gl3, derelict.glfw3.glfw3, derelict.imgui.imgui;
import imgui, texture, kernel;

extern(C) nothrow void ErrorCallback(int error, const(char)* description)
{
	import std.stdio;
    import std.conv;
	try writefln("glfw err: %s ('%s')",error, to!string(description));
	catch {}
}

void main(string[] args)
{
	// Initialize OpenGL
	DerelictGL3.load();
	DerelictGLFW3.load(); 	// Loads GLFW3
	DerelictImgui.load();

	glfwSetErrorCallback(&ErrorCallback);
	assert (glfwInit(), "Failed to initialize GLFW3");
	scope (exit) glfwTerminate();

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, true);

	auto window = glfwCreateWindow(800, 600, "Computer Graphics Image Processing Frameowork", null, null);	
	assert (window !is null);
	
	glfwMakeContextCurrent(window);
	auto vers = DerelictGL3.reload();
	
	// Do IMGUI binding
	glClearColor(0.2, 0.2, 0.2, 1.0);
	ImGuiInit(window, true);
	char[1024] buffer = "Texture t;\n\nkernel(x,y)\n{\n   return k;\n}";
	float[4] fl;

	// Texture 1 example
	Texture!(float) t1 = new Texture!(float)();
					t1.size = [512,512];
					t1.data.length = 512*512*t1.C;
	for (uint i=0; i<t1.data.length; ++i) t1.data[i] = std.random.uniform(0.0f, 1.0f);
					t1.upload();

	// Texture 2 example
	Texture!(float) t2 = new Texture!(float)();
					t2.data[0..t2.data.length] = 0.2f;
	for (uint i=0; i<t2.data.length; i+=3) t2.data[i] = std.random.uniform(0.0f, 1.0f);
					t2.upload();

	// Texture 3 example
	Texture!(float) t3 = new Texture!(float)();
					t3.size = [64,64];
					t3.data.length = 64*64*t3.C;
					for (uint i=0; i<t3.data.length; ++i) t3.data[i] = std.random.uniform(0.0f, 1.0f);
					t3.upload();

	// GPU compute kernel
	Kernel k = new Kernel(
			"#version 430\n"
			"uniform float roll;\n"
			"layout (binding=0) writeonly uniform image2D destTex;\n"
			"layout (local_size_x = 16, local_size_y = 16) in;\n"
			"void main() {\n"
				"\tivec2 storePos = ivec2(gl_GlobalInvocationID.xy);\n"
				"\tfloat localCoef = length(vec2(ivec2(gl_LocalInvocationID.xy)-8)/8.0);\n"
				"\tfloat globalCoef = sin(float(gl_WorkGroupID.x+gl_WorkGroupID.y)*0.1 + roll)*0.5;\n"
				"\timageStore(destTex, storePos, vec4(1-globalCoef*localCoef, 1-globalCoef*localCoef*0.5, 1-globalCoef*localCoef*0.5, 1.0));\n"
			"}"
		);
		k.upload(t2, "destTex");
		k.execute();

	bool windowOpen = true;

	while (!glfwWindowShouldClose(window))
	{
		ImGuiIO* io = ig_GetIO();
		glfwPollEvents();

		for (uint i=0; i<t3.data.length; ++i) t3.data[i] = std.random.uniform(0.0f, 1.0f);
		t3.upload();
		k.execute();

		ImGuiNewFrame();
		if (windowOpen)
		{
			ig_Begin("Image Processing", &windowOpen, ImGuiWindowFlags_NoTitleBar); // | ImGuiWindowFlags_NoTitleBar
			ig_Image(cast(void*)t1.id, ImVec2(128,128)); ig_SameLine();
			ig_Image(cast(void*)t2.id, ImVec2(128,128)); ig_SameLine();
			ig_Image(cast(void*)t3.id, ImVec2(128,128));
			ig_InputTextMultiline("", cast(char*)toStringz(k.code), 1024, ImVec2(394,100));
			ig_End();
		}
		ig_ShowTestWindow();

		if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
			glfwSetWindowShouldClose(window, GL_TRUE);
	
		glClear(GL_COLOR_BUFFER_BIT);
		ig_Render();
		
		glfwSwapBuffers(window);
	}

	glfwDestroyWindow(window);
	glfwTerminate();
}