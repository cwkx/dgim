module app;

import derelict.opengl3.gl3,derelict.glfw3.glfw3,derelict.imgui.imgui;
import std.string;
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
		k = new Kernel(
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
	}

	void render(GLFWwindow* window)
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
}

