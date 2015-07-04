// Copyright 2015 Chris G. Willcocks
// License: GNU General Public License Version 3

import app,texture,kernel,imgui;
import derelict.opengl3.gl3,derelict.glfw3.glfw3,derelict.imgui.imgui;
import std.stdio,std.string;

App logic;

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
	glfwSetWindowSizeCallback(window, &ResizeCallback);

	auto vers = DerelictGL3.reload();
	ImGuiInit(window, true);

	// Setup
	logic = new App();

	while (!glfwWindowShouldClose(window))
		logic.render(window);

	glfwDestroyWindow(window);
	glfwTerminate();
}

extern(C) nothrow void ErrorCallback(int error, const(char)* description)
{
	import std.stdio;
	import std.conv;
	try writefln("glfw err: %s ('%s')",error, to!string(description));
	catch {}
}

extern(C) nothrow void ResizeCallback(GLFWwindow* window, int x, int y)
{
	try {
		glViewport(0, 0, x, y);
		logic.render(window);
	}
	catch {}
}
