import android.media.AudioManager;
import android.media.AudioTrack;
import android.media.AudioFormat;

public class AudioKeepalive {
    public static void main(String[] args) throws Exception {
        int sampleRate = 48000;
        int channelConfig = AudioFormat.CHANNEL_OUT_STEREO;
        int audioFormat = AudioFormat.ENCODING_PCM_16BIT;
        int bufferSize = 4800;

        AudioTrack track = new AudioTrack(
            AudioManager.STREAM_SYSTEM,
            sampleRate,
            channelConfig,
            audioFormat,
            bufferSize,
            AudioTrack.MODE_STREAM
        );

        // Low amplitude, non-zero — ensures signal reaches the audio bridge
        track.setVolume(0.003f);
        track.play();

        // 15Hz sine wave — below human hearing threshold
        byte[] buffer = new byte[bufferSize];
        double frequency = 15.0;
        for (int i = 0; i < bufferSize / 2; i++) {
            double sample = Math.sin(2.0 * Math.PI * frequency * i / sampleRate);
            short s = (short)(sample * 800);
            buffer[i * 2]     = (byte)(s & 0xFF);
            buffer[i * 2 + 1] = (byte)((s >> 8) & 0xFF);
        }

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            track.stop();
            track.release();
        }));

        while (!Thread.currentThread().isInterrupted()) {
            track.write(buffer, 0, buffer.length);
        }
    }
}
