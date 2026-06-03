export interface TryOnResponse {
  status: string;
  result_image_path: string;
  result_image_url: string;
  masked_image_path?: string | null;
  masked_image_url?: string | null;
  duration_seconds: number;
  provider: string;
}

interface RunTryOnParams {
  person: File;
  garmentImageUrl: string;
  prompt: string;
  steps?: number;
  seed?: number;
  autoCrop?: boolean;
}

const aiServiceUrl = process.env.NEXT_PUBLIC_AI_SERVICE_URL || 'http://localhost:8010';

export const tryOnApi = {
  run: async ({
    person,
    garmentImageUrl,
    prompt,
    steps = 12,
    seed = 42,
    autoCrop = true,
  }: RunTryOnParams): Promise<TryOnResponse> => {
    const garment = await imageUrlToFile(garmentImageUrl, 'garment.jpg');
    const formData = new FormData();

    formData.append('person', person);
    formData.append('garment', garment);
    formData.append('prompt', prompt);
    formData.append('steps', String(steps));
    formData.append('seed', String(seed));
    formData.append('auto_mask', 'true');
    formData.append('auto_crop', String(autoCrop));

    const response = await fetch(`${aiServiceUrl}/try-on`, {
      method: 'POST',
      body: formData,
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(errorText || 'Try-on request failed.');
    }

    return response.json();
  },
};

async function imageUrlToFile(url: string, filename: string): Promise<File> {
  const response = await fetch(resolveImageUrl(url));
  if (!response.ok) {
    throw new Error('Product image could not be loaded for try-on.');
  }

  const blob = await response.blob();
  return new File([blob], filename, {
    type: blob.type || 'image/jpeg',
  });
}

function resolveImageUrl(url: string): string {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }

  if (url.startsWith('/')) {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5195/api';
    const apiOrigin = apiUrl.replace(/\/api\/?$/, '');
    return `${apiOrigin}${url}`;
  }

  return url;
}
