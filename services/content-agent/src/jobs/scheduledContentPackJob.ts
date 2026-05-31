import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  readContentPackSource,
  writeScheduledContentPack,
  type ContentPackProfile,
} from "../domain/contentPackBuilder.js";

interface JobOptions {
  sourcePath: string;
  outputDir: string;
  profile: ContentPackProfile;
  intervalMinutes: number;
  once: boolean;
}

export async function runScheduledContentPackJob(
  options: JobOptions,
): Promise<void> {
  const runOnce = async () => {
    const source = await readContentPackSource(options.sourcePath);
    const result = await writeScheduledContentPack({
      source,
      outputDir: options.outputDir,
      profile: options.profile,
    });
    const status = result.ok ? "generated" : "blocked";
    console.log(
      JSON.stringify(
        {
          status,
          outputDir: options.outputDir,
          errors: result.errors,
          warnings: result.warnings,
          manifestId: result.manifest?.manifestId,
        },
        null,
        2,
      ),
    );
  };

  await runOnce();
  if (options.once) {
    return;
  }

  setInterval(runOnce, options.intervalMinutes * 60 * 1000);
}

function parseOptions(argv: string[]): JobOptions {
  const sourcePath =
    valueAfter(argv, "--source") ??
    process.env.CONTENT_PACK_SOURCE_PATH ??
    path.resolve(process.cwd(), "../../assets/content/seed_content.json");
  const outputDir =
    valueAfter(argv, "--output") ??
    process.env.CONTENT_PACK_OUTPUT_DIR ??
    path.resolve(process.cwd(), ".generated/content-pack");
  const profile = normalizeProfile(
    valueAfter(argv, "--profile") ?? process.env.CONTENT_PACK_PROFILE ?? "dev",
  );
  const intervalMinutes = Number(
    valueAfter(argv, "--interval-minutes") ??
      process.env.CONTENT_PACK_INTERVAL_MINUTES ??
      "1440",
  );

  return {
    sourcePath,
    outputDir,
    profile,
    intervalMinutes: Number.isFinite(intervalMinutes) ? intervalMinutes : 1440,
    once: !argv.includes("--schedule"),
  };
}

function valueAfter(argv: string[], flag: string): string | undefined {
  const index = argv.indexOf(flag);
  return index >= 0 ? argv[index + 1] : undefined;
}

function normalizeProfile(value: string): ContentPackProfile {
  return value === "beta" ? "beta" : "dev";
}

if (fileURLToPath(import.meta.url) === process.argv[1]) {
  runScheduledContentPackJob(parseOptions(process.argv.slice(2))).catch(
    (error) => {
      console.error(error);
      process.exitCode = 1;
    },
  );
}
