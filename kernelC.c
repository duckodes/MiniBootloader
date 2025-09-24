void kernel_main() {
    char* video_memory = (char*)0xB8000;
    video_memory[2] = 'H';
    video_memory[3] = 0x0F;
    video_memory[4] = 'i';
    video_memory[5] = 0x0F;
}