#!/usr/bin/env -S deno run --allow-read --allow-write --allow-run --allow-env

/**
 * Updates a single Nix package and outputs version info for GitHub Actions.
 *
 * Usage: deno run --allow-all scripts/update-package/main.ts <package-name>
 *
 * Exit codes:
 *   0 - Success (update applied or already up-to-date)
 *   1 - Error (update or build failed)
 */

import { z } from "npm:zod@3.24.1";

const UpdateMethod = z.enum(["nix-update", "custom"]);

const PackageConfig = z.object({
  name: z.string().min(1),
  nixAttr: z.string().optional(),
  buildAttr: z.string().optional(),
  method: UpdateMethod.optional(),
});

const AutoUpdateConfig = z.object({
  packages: z.array(PackageConfig).min(1),
});

type PackageConfig = z.infer<typeof PackageConfig>;
type AutoUpdateConfig = z.infer<typeof AutoUpdateConfig>;

async function run(
  cmd: string[],
): Promise<{ success: boolean; output: string }> {
  const command = new Deno.Command(cmd[0], {
    args: cmd.slice(1),
    stdout: "piped",
    stderr: "piped",
  });

  const { code, stdout, stderr } = await command.output();
  const output =
    new TextDecoder().decode(stdout) + new TextDecoder().decode(stderr);

  return { success: code === 0, output };
}

async function runPassthrough(cmd: string[]): Promise<boolean> {
  const command = new Deno.Command(cmd[0], {
    args: cmd.slice(1),
    stdout: "inherit",
    stderr: "inherit",
  });

  const { code } = await command.output();
  return code === 0;
}

async function getVersion(attr: string): Promise<string> {
  const { success, output } = await run([
    "nix",
    "eval",
    `.#${attr}.version`,
    "--raw",
  ]);
  return success ? output.trim() : "unknown";
}

function output(key: string, value: string): void {
  console.log(`${key}=${value}`);

  const githubOutput = Deno.env.get("GITHUB_OUTPUT");
  if (githubOutput) {
    Deno.writeTextFileSync(githubOutput, `${key}=${value}\n`, { append: true });
  }
}

function loadConfig(configPath: string): AutoUpdateConfig {
  const raw = Deno.readTextFileSync(configPath);
  const json: unknown = JSON.parse(raw);
  const result = AutoUpdateConfig.safeParse(json);

  if (!result.success) {
    console.error("ERROR: Invalid auto-update.json:");
    for (const issue of result.error.issues) {
      console.error(`  - ${issue.path.join(".")}: ${issue.message}`);
    }
    Deno.exit(1);
  }

  return result.data;
}

function findPackage(config: AutoUpdateConfig, name: string): PackageConfig {
  const pkg = config.packages.find((p: PackageConfig) => p.name === name);
  if (!pkg) {
    console.error(`ERROR: Package "${name}" not found in auto-update.json`);
    console.error("Available packages:");
    for (const p of config.packages) {
      console.error(`  - ${p.name}`);
    }
    Deno.exit(1);
  }
  return pkg;
}

async function main(): Promise<void> {
  const packageName = Deno.args[0];
  if (!packageName) {
    console.error("Usage: main.ts <package-name>");
    Deno.exit(1);
  }

  const scriptDir = new URL(".", import.meta.url).pathname;
  const repoRoot = scriptDir.replace(/\/scripts\/update-package\/$/, "");
  Deno.chdir(repoRoot);

  Deno.env.set("NIX_PATH", "nixpkgs=flake:nixpkgs");

  const configPath = `${repoRoot}/auto-update.json`;
  const config = loadConfig(configPath);
  const pkg = findPackage(config, packageName);

  const nixAttr = pkg.nixAttr ?? packageName;
  const buildAttr = pkg.buildAttr ?? packageName;
  const method = pkg.method ?? "nix-update";

  console.log(`=== Updating ${packageName} ===`);
  console.log(`nixAttr: ${nixAttr}`);
  console.log(`buildAttr: ${buildAttr}`);
  console.log(`method: ${method}`);

  const oldVersion = await getVersion(buildAttr);
  console.log(`Current version: ${oldVersion}`);

  // Run update
  const updateSuccess = await (async () => {
    switch (method) {
      case "nix-update":
        return await runPassthrough([
          "nix-update",
          nixAttr,
          "--flake",
          "--commit",
        ]);
      case "custom":
        return await runPassthrough([`./packages/${packageName}/update.sh`]);
    }
  })();

  if (!updateSuccess) {
    console.error(`ERROR: Update failed for ${packageName}`);
    Deno.exit(1);
  }

  // Stage changes so nix flake can see updated files
  await run(["git", "add", "-A"]);

  const newVersion = await getVersion(buildAttr);
  console.log(`New version: ${newVersion}`);

  if (oldVersion !== newVersion) {
    output("updated", "true");
    output("old_version", oldVersion);
    output("new_version", newVersion);

    // Build and verify
    console.log(`Building ${buildAttr}...`);
    if (
      !(await runPassthrough([
        "nix",
        "build",
        `.#${buildAttr}`,
        "--print-build-logs",
      ]))
    ) {
      console.error(`ERROR: Build failed for ${buildAttr}`);
      Deno.exit(1);
    }

    // Run per-package check script if exists
    const checkScript = `./packages/${buildAttr}/check.sh`;
    try {
      const stat = await Deno.stat(checkScript);
      if (stat.isFile) {
        console.log(`Running check script for ${buildAttr}...`);
        if (!(await runPassthrough([checkScript]))) {
          console.error(`ERROR: Check failed for ${buildAttr}`);
          Deno.exit(1);
        }
      }
    } catch {
      // check.sh doesn't exist, skip
    }

    console.log(
      `SUCCESS: ${packageName} updated from ${oldVersion} to ${newVersion}`,
    );
  } else {
    output("updated", "false");
    console.log(`INFO: ${packageName} is already up-to-date`);
  }
}

main();
