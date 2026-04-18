#!/usr/bin/env python3
"""
ComfyUI API 集成

用于调用本地 ComfyUI 生成 AI 线条画风格图片

使用方法:
    python3 comfyui_api.py --prompt "大鳄龟潜伏在水底" --output output/frames/
    python3 comfyui_api.py --check  # 检查 ComfyUI 连接状态
"""

import os
import sys
import json
import time
import base64
import argparse
from pathlib import Path
from typing import Optional, List, Dict
from datetime import datetime
import requests


class ComfyUIAPI:
    """ComfyUI API 客户端"""

    def __init__(
        self,
        host: str = "127.0.0.1",
        port: int = 8188,
        workflow_path: Optional[str] = None
    ):
        self.host = host
        self.port = port
        self.base_url = f"http://{host}:{port}"
        self.workflow_path = workflow_path
        self.client_id = f"client_{int(time.time())}"

        # 检查连接状态
        self._check_connection()

    def _check_connection(self) -> bool:
        """检查 ComfyUI 连接状态"""
        try:
            response = requests.get(f"{self.base_url}/system_stats", timeout=5)
            if response.status_code == 200:
                return True
        except requests.exceptions.RequestException:
            pass
        return False

    def is_ready(self) -> bool:
        """检查 ComfyUI 是否就绪"""
        return self._check_connection()

    def get_models(self) -> Dict:
        """获取可用模型列表"""
        try:
            response = requests.get(f"{self.base_url}/api/models", timeout=10)
            if response.status_code == 200:
                return response.json()
        except Exception as e:
            print(f"获取模型列表失败: {e}")
        return {}

    def queue_prompt(self, prompt_data: Dict) -> Optional[str]:
        """
        将提示词加入队列

        Args:
            prompt_data: ComfyUI 工作流数据

        Returns:
            prompt_id 用于查询进度
        """
        try:
            response = requests.post(
                f"{self.base_url}/api/prompt",
                json={"prompt": prompt_data, "client_id": self.client_id},
                timeout=30
            )

            if response.status_code == 200:
                result = response.json()
                return result.get("prompt_id")
        except Exception as e:
            print(f"队列提交失败: {e}")
        return None

    def get_progress(self, prompt_id: str) -> Dict:
        """获取生成进度"""
        try:
            response = requests.get(
                f"{self.base_url}/api/history/{prompt_id}",
                timeout=10
            )
            if response.status_code == 200:
                return response.json()
        except Exception as e:
            print(f"获取进度失败: {e}")
        return {}

    def wait_for_completion(
        self,
        prompt_id: str,
        timeout: int = 300,
        poll_interval: int = 2
    ) -> Optional[Dict]:
        """
        等待任务完成

        Args:
            prompt_id: 提示词ID
            timeout: 超时时间(秒)
            poll_interval: 轮询间隔(秒)

        Returns:
            完成结果
        """
        start_time = time.time()

        while time.time() - start_time < timeout:
            result = self.get_progress(prompt_id)

            if result:
                # 检查是否有错误
                if "status" in result:
                    if result["status"].get("err"):
                        print(f"生成错误: {result['status']['err']}")
                        return None

                    if result["status"].get("completed"):
                        return result

            time.sleep(poll_interval)

        print("生成超时")
        return None

    def get_history(self, prompt_id: str) -> Dict:
        """获取历史记录"""
        try:
            response = requests.get(
                f"{self.base_url}/api/history/{prompt_id}",
                timeout=10
            )
            if response.status_code == 200:
                return response.json()
        except Exception as e:
            print(f"获取历史失败: {e}")
        return {}

    def download_image(self, image_path: str, output_dir: str) -> Optional[str]:
        """
        下载生成的图片

        Args:
            image_path: ComfyUI 输出路径
            output_dir: 保存目录

        Returns:
            本地文件路径
        """
        try:
            # 构建完整的 URL
            if image_path.startswith("http"):
                url = image_path
            else:
                # 相对路径转换为完整 URL
                filename = Path(image_path).name
                url = f"{self.base_url}/view?filename={filename}"

            response = requests.get(url, timeout=60)

            if response.status_code == 200:
                output_path = Path(output_dir) / Path(image_path).name
                output_path.parent.mkdir(parents=True, exist_ok=True)

                with open(output_path, "wb") as f:
                    f.write(response.content)

                return str(output_path)
        except Exception as e:
            print(f"下载图片失败: {e}")
        return None

    def get_output_images(self, prompt_id: str, output_dir: str) -> List[str]:
        """
        获取所有输出图片

        Args:
            prompt_id: 提示词ID
            output_dir: 保存目录

        Returns:
            图片路径列表
        """
        import shutil

        result = self.get_history(prompt_id)
        images = []

        # ComfyUI 默认输出目录
        comfy_output = Path.home() / "ComfyUI" / "output"

        if result and "outputs" in result:
            for node_id, node_data in result["outputs"].items():
                # 检查是否有图片输出
                if "images" in node_data:
                    for img in node_data["images"]:
                        image_path = img.get("filename")
                        if image_path:
                            # 直接从 ComfyUI output 目录复制
                            source = comfy_output / image_path
                            if source.exists():
                                output_path = Path(output_dir) / image_path
                                output_path.parent.mkdir(parents=True, exist_ok=True)
                                shutil.copy(source, output_path)
                                images.append(str(output_path))
                                print(f"已复制图片: {image_path}")
                            else:
                                # 尝试通过 API 下载
                                print(f"文件不存在，尝试 API 下载: {image_path}")
                                local_path = self.download_image(image_path, output_dir)
                                if local_path:
                                    images.append(local_path)

        if not images:
            # 如果没有从历史获取到图片，复制最新的 lineart 图片
            print("从历史未获取到图片，查找最新图片...")
            lineart_files = sorted(comfy_output.glob("lineart_*.png"))
            if lineart_files:
                latest = lineart_files[-1]
                output_path = Path(output_dir) / latest.name
                shutil.copy(latest, output_path)
                images.append(str(output_path))
                print(f"复制最新图片: {latest.name}")

        return images


class LineArtWorkflow:
    """线条画生成工作流"""

    # 默认 SDXL + ControlNet Lineart 工作流
    DEFAULT_WORKFLOW = {
        "3": {
            "class_type": "KSampler",
            "inputs": {
                "model": ["4", 0],
                "positive": ["6", 0],
                "negative": ["7", 0],
                "sampler_name": "euler",
                "scheduler": "normal",
                "steps": 25,
                "cfg": 8.0,
                "seed": 42
            }
        },
        "4": {
            "class_type": "CheckpointLoaderSimple",
            "inputs": {
                "ckpt_name": "sdxl1.0.safetensors"
            }
        },
        "5": {
            "class_type": "CLIPLoader",
            "inputs": {
                "clip_type": "sd3",
                "model_name": "sdxl1.0.safetensors"
            }
        },
        "6": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": "",
                "clip": ["5", 0]
            }
        },
        "7": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": "",
                "clip": ["5", 0]
            }
        },
        "8": {
            "class_type": "ControlNetName",
            "inputs": {
                "control_net_name": "control_v11p_sd15_lineart.pth"
            }
        },
        "9": {
            "class_type": "ControlNetApply",
            "inputs": {
                "强度": 0.8,
                "start_percent": 0.0,
                "end_percent": 1.0
            }
        },
        "10": {
            "class_type": "EmptyLatentImage",
            "inputs": {
                "width": 1280,
                "height": 720,
                "batch_size": 1
            }
        },
        "11": {
            "class_type": "VAEDecode",
            "inputs": {
                "samples": ["3", 0],
                "vae": ["4", 2]
            }
        },
        "12": {
            "class_type": "SaveImage",
            "inputs": {
                "filename_prefix": "lineart",
                "images": ["11", 0]
            }
        }
    }

    def __init__(self, api: ComfyUIAPI):
        self.api = api

    def generate_lineart(
        self,
        prompt: str,
        negative_prompt: str = "",
        width: int = 1280,
        height: int = 720,
        steps: int = 25,
        cfg: float = 8.0,
        seed: int = -1,
        control_image: Optional[str] = None,
        output_dir: str = "output/frames"
    ) -> Optional[List[str]]:
        """
        生成线条画风格图片

        Args:
            prompt: 正向提示词
            negative_prompt: 负向提示词
            width: 图片宽度
            height: 图片高度
            steps: 采样步数
            cfg: CFG 强度
            seed: 随机种子 (-1 随机)
            control_image: 控制线条图片路径
            output_dir: 输出目录

        Returns:
            生成的图片路径列表
        """
        if not self.api.is_ready():
            print("错误: ComfyUI 未连接，请先启动 ComfyUI")
            print("启动命令: python main.py --listen 0.0.0.0 --port 8188")
            return None

        # 如果 seed 为 -1，则随机生成
        if seed == -1:
            import random
            seed = random.randint(0, 2**32 - 1)

        # 构建工作流
        workflow = self._build_workflow(
            prompt=prompt,
            negative_prompt=negative_prompt,
            width=width,
            height=height,
            steps=steps,
            cfg=cfg,
            seed=seed,
            control_image=control_image
        )

        # 提交任务
        print(f"提交生成任务... (seed: {seed})")
        prompt_id = self.api.queue_prompt(workflow)

        if not prompt_id:
            print("任务提交失败")
            return None

        print("正在生成...")
        result = self.api.wait_for_completion(prompt_id, timeout=600)

        if result:
            print("生成完成!")
            images = self.api.get_output_images(prompt_id, output_dir)
            return images

        return None

    def _build_workflow(
        self,
        prompt: str,
        negative_prompt: str,
        width: int,
        height: int,
        steps: int,
        cfg: float,
        seed: int,
        control_image: Optional[str]
    ) -> Dict:
        """构建生成工作流 - 兼容 SDXL"""

        workflow = {
            # 1: 加载 SDXL 模型
            "1": {
                "class_type": "CheckpointLoaderSimple",
                "inputs": {"ckpt_name": "sdxl1.0.safetensors"}
            },
            # 2: SDXL 正向提示词
            "2": {
                "class_type": "CLIPTextEncodeSDXL",
                "inputs": {
                    "clip": ["1", 1],
                    "width": width,
                    "height": height,
                    "crop_w": 0,
                    "crop_h": 0,
                    "target_width": width,
                    "target_height": height,
                    "text_g": prompt,
                    "text_l": ""
                }
            },
            # 3: 负向提示词 (使用普通 CLIPTextEncode)
            "3": {
                "class_type": "CLIPTextEncode",
                "inputs": {
                    "text": negative_prompt if negative_prompt else "low quality, blurry, distorted",
                    "clip": ["1", 1]
                }
            },
            # 4: 隐空间图像
            "4": {
                "class_type": "EmptyLatentImage",
                "inputs": {"width": width, "height": height, "batch_size": 1}
            },
            # 5: KSampler
            "5": {
                "class_type": "KSampler",
                "inputs": {
                    "model": ["1", 0],
                    "seed": seed,
                    "steps": steps,
                    "cfg": cfg,
                    "sampler_name": "euler_ancestral",
                    "scheduler": "normal",
                    "positive": ["2", 0],
                    "negative": ["3", 0],
                    "latent_image": ["4", 0],
                    "denoise": 1.0
                }
            },
            # 6: VAE 解码
            "6": {
                "class_type": "VAEDecode",
                "inputs": {
                    "samples": ["5", 0],
                    "vae": ["1", 2]
                }
            },
            # 7: 保存图像
            "7": {
                "class_type": "SaveImage",
                "inputs": {
                    "filename_prefix": "lineart",
                    "images": ["6", 0]
                }
            }
        }

        return workflow


def generate_lineart_images(
    prompts: List[Dict],
    output_dir: str = "output/frames",
    comfyui_host: str = "127.0.0.1",
    comfyui_port: int = 8188
) -> List[str]:
    """
    批量生成线条画图片

    Args:
        prompts: 分镜提示词列表，每个包含 prompt, negative_prompt, scene_id
        output_dir: 输出目录
        comfyui_host: ComfyUI 地址
        comfyui_port: ComfyUI 端口

    Returns:
        生成的图片路径列表
    """
    api = ComfyUIAPI(host=comfyui_host, port=comfyui_port)
    workflow = LineArtWorkflow(api)

    all_images = []
    total = len(prompts)

    for i, p in enumerate(prompts, 1):
        print(f"\n[{i}/{total}] 生成场景 {p.get('scene_id', i)}...")

        scene_dir = Path(output_dir) / f"scene_{p.get('scene_id', i):03d}"
        scene_dir.mkdir(parents=True, exist_ok=True)

        images = workflow.generate_lineart(
            prompt=p.get("prompt", ""),
            negative_prompt=p.get("negative_prompt", ""),
            output_dir=str(scene_dir)
        )

        if images:
            all_images.extend(images)
            print(f"  生成 {len(images)} 张图片")
        else:
            print(f"  生成失败")

    return all_images


def check_comfyui_status(host: str = "127.0.0.1", port: int = 8188):
    """检查 ComfyUI 状态"""
    api = ComfyUIAPI(host=host, port=port)

    print("=" * 50)
    print("ComfyUI 状态检查")
    print("=" * 50)

    if api.is_ready():
        print("✓ ComfyUI 运行正常")

        # 获取系统信息
        try:
            response = requests.get(f"{api.base_url}/system_stats", timeout=5)
            stats = response.json()
            print(f"\n系统信息:")
            print(f"  内存使用: {stats.get('memory_used', 'N/A')} / {stats.get('memory_total', 'N/A')}")
            print(f"  GPU: {stats.get('gpu', 'N/A')}")
        except:
            pass

        # 获取可用模型
        models = api.get_models()
        if models:
            print(f"\n可用模型:")
            for model in models.get("models", [])[:5]:
                print(f"  - {model}")
    else:
        print("✗ ComfyUI 未连接")
        print("\n请确保 ComfyUI 已启动:")
        print(f"  cd ~/ComfyUI")
        print(f"  python main.py --listen {host} --port {port}")
        print(f"\n启动后访问: http://{host}:{port}")


def main():
    parser = argparse.ArgumentParser(description="ComfyUI API 集成工具")
    parser.add_argument("--check", action="store_true", help="检查 ComfyUI 连接状态")
    parser.add_argument("--prompt", "-p", help="生成提示词")
    parser.add_argument("--negative", "-n", default="", help="负向提示词")
    parser.add_argument("--output", "-o", default="output/frames", help="输出目录")
    parser.add_argument("--host", default="127.0.0.1", help="ComfyUI 地址")
    parser.add_argument("--port", type=int, default=8188, help="ComfyUI 端口")
    parser.add_argument("--width", type=int, default=1280, help="图片宽度")
    parser.add_argument("--height", type=int, default=720, help="图片高度")

    args = parser.parse_args()

    # 检查状态
    if args.check:
        check_comfyui_status(args.host, args.port)
        return

    # 生成图片
    if args.prompt:
        api = ComfyUIAPI(host=args.host, port=args.port)
        workflow = LineArtWorkflow(api)

        images = workflow.generate_lineart(
            prompt=args.prompt,
            negative_prompt=args.negative,
            width=args.width,
            height=args.height,
            output_dir=args.output
        )

        if images:
            print(f"\n生成成功: {len(images)} 张图片")
            for img in images:
                print(f"  - {img}")
        else:
            print("\n生成失败")
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
