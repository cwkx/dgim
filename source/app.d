// Copyright 2015 Chris G. Willcocks
// License: GNU General Public License Version 3

module app;

import std.stdio, derelict.opengl3.gl3,derelict.glfw3.glfw3,derelict.imgui.imgui;
import gl3n.linalg, core.time, std.string, std.file;
import texture,kernel,imgui;

class App
{
	Texture!(float) t1;
	Texture!(float) t2;
	Texture!(float) t3;
	Kernel k;

	bool windowOpen = true;

	this()
	{
		// Do IMGUI binding
		glClearColor(0.2, 0.2, 0.2, 1.0);

		// Texture 1 example
		t1 = new Texture!(float)();
		t1.size = [512,512];
		t1.data.length = 512*512*t1.C;
		for (uint i=0; i<t1.data.length; ++i) t1.data[i] = std.random.uniform(0.0f, 1.0f);
		t1.upload();
		
		// Texture 2 example
		t2 = new Texture!(float)();
		t2.size = [256,256];
		t2.data.length = 256*256*t2.C;
		t2.data[0..t2.data.length] = 0.2f;
		for (uint i=0; i<t2.data.length; i+=3) t2.data[i] = std.random.uniform(0.0f, 1.0f);
		t2.upload();
		
		// Texture 3 example
		t3 = new Texture!(float)();
		t3.size = [64,64];
		t3.data.length = 64*64*t3.C;
		for (uint i=0; i<t3.data.length; ++i) t3.data[i] = std.random.uniform(0.0f, 1.0f);
		t3.upload();
		
		// GPU compute kernel
		k = new Kernel(std.file.readText("data/generators.comp"));
		k.upload("destTex", t2);
		k.execute();
	}

	void render(GLFWwindow* window)
	{
		ImGuiIO* io = ig_GetIO();
		glfwPollEvents();

		for (uint i=0; i<t3.data.length; ++i) t3.data[i] = std.random.uniform(0.0f, 1.0f);
		t3.upload();

		// send shadertoy params
		double mouseX, mouseY; glfwGetCursorPos(window, &mouseX, &mouseY);
		k.upload("iResolution", vec3(t2.size[0], t2.size[1], 0));
		k.upload("iGlobalTime", glfwGetTime());
		k.upload("iMouse", vec4(mouseX,mouseY,ig_IsMouseDown(0),ig_IsMouseDown(1)));
		k.execute();

		ImGuiNewFrame();
		if (windowOpen)
		{
			ig_Begin("Image Processing", &windowOpen, ImGuiWindowFlags_NoScrollbar); // | 
			ImVec2 size;
			ig_GetWindowSize(&size); size.x = max(size.x, 256); size.y = max(size.y,256);
			ig_Image(cast(void*)t2.id, size);
			/*ig_Columns(2, "columns");
			ig_Image(cast(void*)t2.id, ImVec2(ig_GetColumnWidth(0)-10, size.y)); ig_NextColumn();
			ig_InputTextMultiline("", cast(char*)toStringz(k.code), 10240, ImVec2(size.x-ig_GetColumnWidth(0), size.y)); */
			ig_End();
		}
		ig_ShowMetricsWindow();

		ig_Image(cast(void*)t1.id, ImVec2(128,128)); ig_SameLine();
		ig_Image(cast(void*)t3.id, ImVec2(128,128));
		
		if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
			glfwSetWindowShouldClose(window, GL_TRUE);
		
		glClear(GL_COLOR_BUFFER_BIT);
		ig_Render();
		
		glfwSwapBuffers(window);
	}
}

