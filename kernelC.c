void kernel_main() {
    char* video_memory = (char*)0xB8000;
    video_memory[6] = 'H';
    video_memory[7] = 0x0F;
    video_memory[8] = 'i';
    video_memory[9] = 0x0F;
}