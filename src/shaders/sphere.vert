#version 330 core

layout (location = 0) in vec3 vertexPosition;
layout (location = 1) in vec3 vertexNormal;
layout (location = 2) in vec2 vertexUV;

out vec3 fragNormal;
out vec3 fragPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    fragPos = vec3(model * vec4(vertexPosition, 1.0));
    fragNormal = mat3(transpose(inverse(model))) * vertexNormal;

    gl_Position = projection * view * vec4(fragPos, 1.0);
}
